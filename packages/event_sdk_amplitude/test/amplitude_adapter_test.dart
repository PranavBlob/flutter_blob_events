import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_amplitude/event_sdk_amplitude.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient implements AmplitudeAnalyticsClient {
  AmplitudeConfig? initializedWith;
  final List<Event> events = [];
  String? userId;
  Map<String, Object?>? traits;
  var flushCount = 0;

  @override
  Future<void> flush() async {
    flushCount++;
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    this.userId = userId;
    this.traits = traits;
  }

  @override
  Future<void> init(AmplitudeConfig config) async {
    initializedWith = config;
  }

  @override
  Future<void> track(Event event) async {
    events.add(event);
  }
}

void main() {
  test('initializes and delegates Event SDK actions', () async {
    final client = _FakeClient();
    final adapter = AmplitudeAdapter(
      config: const AmplitudeConfig(apiKey: 'api-key', instanceName: 'events'),
      client: client,
    );

    await adapter.init();
    await adapter.track(
      const Event(name: 'signup', props: {'method': 'email'}),
    );
    await adapter.identify('user_123', traits: {'plan': 'pro'});
    await adapter.flush();

    expect(client.initializedWith?.apiKey, 'api-key');
    expect(client.initializedWith?.instanceName, 'events');
    expect(client.events.single.name, 'signup');
    expect(client.userId, 'user_123');
    expect(client.traits, {'plan': 'pro'});
    expect(client.flushCount, 1);
  });
}
