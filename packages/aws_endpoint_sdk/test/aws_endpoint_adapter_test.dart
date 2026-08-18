import 'package:aws_endpoint_sdk/aws_endpoint_sdk.dart';
import 'package:event_sdk/event_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingClient implements AwsEndpointClient {
  final posts = <Map<String, dynamic>>[];

  @override
  Future<void> postEvent({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    posts.add(body);
  }
}

void main() {
  test('builds MobileTrackingEvent payload', () async {
    final client = _RecordingClient();
    final adapter = AwsEndpointAdapter(
      config: const AwsEndpointConfig(
        endpoint: 'https://dev-events.atomapplications.com/api/dev/v1',
        defaultFields: AwsEndpointDefaultFields(
          appName: 'DemoApp',
          platform: 'Android',
          appId: 'app-1',
          deviceId: 'device-1',
          userId: 'user-1',
        ),
      ),
      client: client,
    );

    await adapter.track(
      Event(
        name: 'signup',
        props: {'method': 'email', 'plan': 'free'},
      ),
    );

    expect(client.posts, hasLength(1));
    final body = client.posts.single;
    expect(body['ename'], 'signup');
    expect(body['app'], 'DemoApp');
    expect(body['os'], 'Android');
    expect(body['appId'], 'app-1');
    expect(body['deviceId'], 'device-1');
    expect(body['userId'], 'user-1');
    expect(body['stream'], 'mobile-tracking-event');
    expect(body['parameters'], {'method': 'email', 'plan': 'free'});
  });

  test('identify updates userId in payload', () async {
    final client = _RecordingClient();
    final adapter = AwsEndpointAdapter(
      config: const AwsEndpointConfig(
        endpoint: 'https://example.com/events',
      ),
      client: client,
    );

    await adapter.identify('user_42');
    await adapter.track(Event(name: 'open'));

    expect(client.posts.single['userId'], 'user_42');
  });

  test('skips network when endpoint is empty', () async {
    final client = _RecordingClient();
    final adapter = AwsEndpointAdapter(
      config: const AwsEndpointConfig(endpoint: ''),
      client: client,
    );

    await adapter.track(Event(name: 'noop'));

    expect(client.posts, isEmpty);
  });
}
