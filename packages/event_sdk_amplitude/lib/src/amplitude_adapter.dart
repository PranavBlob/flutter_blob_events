import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:event_sdk/event_sdk.dart';

import 'amplitude_config.dart';

/// Optional seam for tests or a custom Amplitude client.
abstract interface class AmplitudeAnalyticsClient {
  Future<void> init(AmplitudeConfig config);

  Future<void> track(Event event);

  Future<void> identify(String userId, {Map<String, Object?>? traits});

  Future<void> flush();
}

class DefaultAmplitudeAnalyticsClient implements AmplitudeAnalyticsClient {
  Amplitude? _amplitude;

  Amplitude get _client {
    final client = _amplitude;
    if (client == null) {
      throw StateError('Amplitude client has not been initialized.');
    }
    return client;
  }

  @override
  Future<void> init(AmplitudeConfig config) async {
    final client = Amplitude(
      Configuration(
        apiKey: config.apiKey,
        instanceName: config.instanceName ?? '',
      ),
    );
    _amplitude = client;
    await client.isBuilt;
  }

  @override
  Future<void> track(Event event) {
    return _client.track(
      BaseEvent(
        event.name,
        eventProperties: Map<String, dynamic>.from(event.props),
        timestamp: event.timestamp?.millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    await _client.setUserId(userId);
    if (traits == null || traits.isEmpty) return;

    final identify = Identify();
    for (final entry in traits.entries) {
      if (entry.value != null) {
        identify.set(entry.key, entry.value);
      }
    }
    await _client.identify(identify);
  }

  @override
  Future<void> flush() => _client.flush();
}

/// Routes normalized events to Amplitude.
class AmplitudeAdapter implements EventAdapter {
  AmplitudeAdapter({required this.config, AmplitudeAnalyticsClient? client})
    : _client = client ?? DefaultAmplitudeAnalyticsClient();

  final AmplitudeConfig config;
  final AmplitudeAnalyticsClient _client;

  @override
  EventPlatform get platform => EventPlatform.amplitude;

  @override
  Future<void> init() => _client.init(config);

  @override
  Future<void> track(Event event) => _client.track(event);

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) {
    return _client.identify(userId, traits: traits);
  }

  @override
  Future<void> flush() => _client.flush();

  @override
  Future<void> dispose() => Future<void>.value();
}
