import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_adjust/event_sdk_adjust.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient implements AdjustClient {
  AdjustConfig? initializedWith;
  final events = <AdjustEvent>[];
  final globals = <String, String>{};

  @override
  void initSdk(AdjustConfig config) {
    initializedWith = config;
  }

  @override
  void trackEvent(AdjustEvent event) {
    events.add(event);
  }

  @override
  void addGlobalCallbackParameter(String key, String value) {
    globals[key] = value;
  }
}

void main() {
  test('maps event name to token and revenue props', () async {
    final client = _FakeClient();
    final adapter = AdjustAdapter(
      config: const AdjustEventConfig(
        appToken: 'app_token',
        initSdk: false,
        eventTokens: {'purchase': 'tok_purchase'},
      ),
      client: client,
    );

    expect(adapter.platform, EventPlatform.adjust);

    await adapter.track(
      const Event(
        name: 'purchase',
        props: {
          'revenue': 9.99,
          'currency': 'USD',
          'sku': 'pro_monthly',
        },
      ),
    );

    expect(client.events, hasLength(1));
    expect(client.events.single.toMap['eventToken'], 'tok_purchase');
    expect(client.events.single.toMap['revenue'], '9.99');
    expect(client.events.single.toMap['currency'], 'USD');
    expect(client.events.single.toMap['callbackParameters'], contains('sku'));
  });

  test('throws when event name has no Adjust token', () async {
    final adapter = AdjustAdapter(
      config: const AdjustEventConfig(
        appToken: 'app_token',
        initSdk: false,
        eventTokens: {},
      ),
      client: _FakeClient(),
    );

    expect(
      () => adapter.track(const Event(name: 'signup')),
      throwsA(isA<EventSdkException>()),
    );
  });

  test('identify writes user_id as a global callback param', () async {
    final client = _FakeClient();
    final adapter = AdjustAdapter(
      config: const AdjustEventConfig(appToken: 'app_token', initSdk: false),
      client: client,
    );

    await adapter.identify('user_123', traits: {'plan': 'pro'});

    expect(client.globals, {'user_id': 'user_123', 'plan': 'pro'});
  });
}
