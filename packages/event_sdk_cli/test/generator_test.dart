import 'dart:io';

import 'package:event_sdk_cli/src/catalog.dart';
import 'package:event_sdk_cli/src/generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('event_sdk_cli_');
  });

  tearDown(() async {
    if (temp.existsSync()) await temp.delete(recursive: true);
  });

  test('generates valid awsEndpoint factory and EventSdkConfig defaults', () async {
    await writeSetupFile(
      appRoot: temp.path,
      platforms: resolvePlatforms(['aws_endpoint', 'adjust']),
    );

    final config = File(p.join(temp.path, configRelativePath));
    final setup = File(p.join(temp.path, setupRelativePath));
    final configText = await config.readAsString();
    final setupText = await setup.readAsString();

    expect(configText, contains('createAwsEndpointAdapter()'));
    expect(configText, isNot(contains('createAws_endpointAdapter')));
    expect(configText, contains('createAdjustAdapter()'));
    expect(
      configText,
      contains('EventSdkConfig createEventSdkConfig() => EventSdkConfig('),
    );
    expect(configText, contains('defaultParams: eventSdkDefaultParams,'));
    expect(configText, contains('final eventSdkDefaultParams = <String, Object?>{'));
    expect(setupText, contains('config: createEventSdkConfig(),'));
  });

  test('migrates legacy createAws_endpointAdapter name on add', () async {
    final configFile = File(p.join(temp.path, configRelativePath));
    await configFile.parent.create(recursive: true);
    await configFile.writeAsString('''
import 'package:event_sdk/event_sdk.dart';
import 'package:aws_endpoint_sdk/aws_endpoint_sdk.dart';

List<EventAdapter> createEventSdkAdapters() => [
    createAws_endpointAdapter(),
];

EventAdapter createAws_endpointAdapter() => AwsEndpointAdapter(
  config: AwsEndpointConfig(endpoint: 'https://example.com'),
);
''');

    await writeSetupFile(
      appRoot: temp.path,
      platforms: resolvePlatforms(['aws_endpoint']),
    );

    final configText = await configFile.readAsString();
    expect(configText, contains('createAwsEndpointAdapter()'));
    expect(configText, isNot(contains('createAws_endpointAdapter')));
    expect(configText, contains('createEventSdkConfig()'));
    expect(await readEnabledPlatforms(temp.path), {'aws_endpoint'});
  });
}
