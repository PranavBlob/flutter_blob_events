import 'dart:io';

import 'package:event_sdk_cli/src/catalog.dart';
import 'package:event_sdk_cli/src/pubspec_editor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('event_sdk_cli_pubspec_');
  });

  tearDown(() async {
    if (temp.existsSync()) await temp.delete(recursive: true);
  });

  test('adds event_sdk git override so adapters share one source', () async {
    final pubspec = File(p.join(temp.path, 'pubspec.yaml'));
    await pubspec.writeAsString('''
name: event_sdk_demo
environment:
  sdk: ^3.10.0
dependencies:
  flutter:
    sdk: flutter
''');

    await ensureCoreAndPlatformDeps(
      appRoot: temp.path,
      platforms: resolvePlatforms(['adjust']),
      gitUrl: 'https://github.com/PranavBlob/flutter_blob_events.git',
      ref: 'event_sdk',
    );

    final yaml = loadYaml(await pubspec.readAsString()) as YamlMap;
    final deps = yaml['dependencies'] as YamlMap;
    final overrides = yaml['dependency_overrides'] as YamlMap;
    final expectedGit = {
      'url': 'https://github.com/PranavBlob/flutter_blob_events.git',
      'path': 'packages/event_sdk',
      'ref': 'event_sdk',
    };

    expect(_gitMap(deps['event_sdk']), expectedGit);
    expect(_gitMap(deps['event_sdk_adjust'])['path'], 'packages/event_sdk_adjust');
    expect(_gitMap(overrides['event_sdk']), expectedGit);
  });

  test('preserves existing unrelated dependency_overrides', () async {
    final pubspec = File(p.join(temp.path, 'pubspec.yaml'));
    await pubspec.writeAsString('''
name: event_sdk_demo
environment:
  sdk: ^3.10.0
dependencies:
  flutter:
    sdk: flutter
dependency_overrides:
  some_pkg: 1.2.3
''');

    await ensureCoreAndPlatformDeps(
      appRoot: temp.path,
      platforms: resolvePlatforms(['aws']),
      gitUrl: 'https://github.com/PranavBlob/flutter_blob_events.git',
      ref: 'event_sdk',
    );

    final yaml = loadYaml(await pubspec.readAsString()) as YamlMap;
    final overrides = yaml['dependency_overrides'] as YamlMap;
    expect(overrides['some_pkg'], '1.2.3');
    expect(_gitMap(overrides['event_sdk'])['ref'], 'event_sdk');
  });
}

Map<String, Object?> _gitMap(Object? node) {
  final git = (node as YamlMap)['git'] as YamlMap;
  return {
    'url': git['url'],
    'path': git['path'],
    'ref': git['ref'],
  };
}
