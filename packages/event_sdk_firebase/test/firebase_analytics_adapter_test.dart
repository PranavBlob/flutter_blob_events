import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_firebase/event_sdk_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClient implements FirebaseAnalyticsClient {
  final List<(String, Map<String, Object>)> events = [];
  final Map<String, String> userProperties = {};
  String? userId;

  @override
  Future<void> setUserId(String userId) async {
    this.userId = userId;
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    userProperties[name] = value;
  }

  @override
  Future<void> track(String name, Map<String, Object> parameters) async {
    events.add((name, parameters));
  }
}

void main() {
  test('maps compatible event properties for Firebase Analytics', () async {
    final client = _FakeClient();
    final adapter = FirebaseAnalyticsAdapter(client: client);

    await adapter.track(
      const Event(
        name: 'signup',
        props: {
          'method': 'email',
          'attempt': 2,
          'accepted_terms': true,
          'metadata': {'source': 'example'},
          'ignored': null,
        },
      ),
    );

    expect(client.events, hasLength(1));
    expect(client.events.single.$1, 'signup');
    expect(client.events.single.$2, {
      'method': 'email',
      'attempt': 2,
      'accepted_terms': 1,
      'metadata': '{source: example}',
    });
  });

  test('sets Firebase user id and traits', () async {
    final client = _FakeClient();
    final adapter = FirebaseAnalyticsAdapter(client: client);

    await adapter.identify('user_123', traits: {'plan': 'pro', 'age': 28});

    expect(client.userId, 'user_123');
    expect(client.userProperties, {'plan': 'pro', 'age': '28'});
  });
}
