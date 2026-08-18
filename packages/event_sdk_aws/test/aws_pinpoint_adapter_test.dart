import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_aws/event_sdk_aws.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient implements PinpointAnalyticsClient {
  final events = <Event>[];
  String? userId;
  Map<String, Object?>? traits;
  var flushCount = 0;

  @override
  Future<void> recordEvent(Event event) async {
    events.add(event);
  }

  @override
  Future<void> identifyUser(String userId, {Map<String, Object?>? traits}) async {
    this.userId = userId;
    this.traits = traits;
  }

  @override
  Future<void> flushEvents() async {
    flushCount++;
  }
}

void main() {
  test('delegates track, identify, and flush to the Pinpoint client', () async {
    final client = _FakeClient();
    final adapter = AwsPinpointAdapter(
      config: const AwsPinpointConfig(
        amplifyConfig: '{}',
        configureAmplify: false,
      ),
      client: client,
    );

    expect(adapter.platform, EventPlatform.aws);

    await adapter.init();
    await adapter.track(
      const Event(name: 'signup', props: {'method': 'email'}),
    );
    await adapter.identify('user_123', traits: {'plan': 'pro'});
    await adapter.flush();

    expect(client.events.single.name, 'signup');
    expect(client.events.single.props['method'], 'email');
    expect(client.userId, 'user_123');
    expect(client.traits, {'plan': 'pro'});
    expect(client.flushCount, 1);
  });
}
