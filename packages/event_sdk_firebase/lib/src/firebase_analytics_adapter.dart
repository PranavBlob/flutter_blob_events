import 'package:event_sdk/event_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Optional seam for tests or a custom Firebase Analytics client.
abstract interface class FirebaseAnalyticsClient {
  Future<void> track(String name, Map<String, Object> parameters);

  Future<void> setUserId(String userId);

  Future<void> setUserProperty(String name, String value);
}

class DefaultFirebaseAnalyticsClient implements FirebaseAnalyticsClient {
  DefaultFirebaseAnalyticsClient([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> track(String name, Map<String, Object> parameters) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> setUserId(String userId) => _analytics.setUserId(id: userId);

  @override
  Future<void> setUserProperty(String name, String value) {
    return _analytics.setUserProperty(name: name, value: value);
  }
}

/// Routes normalized events to Firebase Analytics.
///
/// The host app must initialize Firebase before [EventSdk.init], usually with
/// `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
class FirebaseAnalyticsAdapter implements EventAdapter {
  FirebaseAnalyticsAdapter({FirebaseAnalyticsClient? client})
    : _client = client ?? DefaultFirebaseAnalyticsClient();

  final FirebaseAnalyticsClient _client;

  @override
  EventPlatform get platform => EventPlatform.firebase;

  @override
  Future<void> init() => Future<void>.value();

  @override
  Future<void> track(Event event) {
    return _client.track(event.name, _firebaseParameters(event.props));
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    await _client.setUserId(userId);
    if (traits == null) return;

    for (final entry in traits.entries) {
      final value = entry.value;
      if (value == null) continue;
      await _client.setUserProperty(entry.key, value.toString());
    }
  }

  /// Firebase Analytics doesn't expose a public manual flush API.
  @override
  Future<void> flush() => Future<void>.value();

  @override
  Future<void> dispose() => Future<void>.value();

  Map<String, Object> _firebaseParameters(Map<String, Object?> props) {
    return {
      for (final entry in props.entries)
        if (entry.value is String || entry.value is num)
          entry.key: entry.value as Object
        else if (entry.value is bool)
          entry.key: (entry.value! as bool) ? 1 : 0
        else if (entry.value != null)
          entry.key: entry.value.toString(),
    };
  }
}
