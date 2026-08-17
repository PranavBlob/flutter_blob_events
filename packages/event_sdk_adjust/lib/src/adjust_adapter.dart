import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:event_sdk/event_sdk.dart';

import 'adjust_event_config.dart';

/// Optional seam for tests.
abstract class AdjustClient {
  void initSdk(AdjustConfig config);
  void trackEvent(AdjustEvent event);
  void addGlobalCallbackParameter(String key, String value);
}

class DefaultAdjustClient implements AdjustClient {
  @override
  void initSdk(AdjustConfig config) => Adjust.initSdk(config);

  @override
  void trackEvent(AdjustEvent event) => Adjust.trackEvent(event);

  @override
  void addGlobalCallbackParameter(String key, String value) {
    Adjust.addGlobalCallbackParameter(key, value);
  }
}

/// Adjust adapter for [EventSdk].
class AdjustAdapter implements EventAdapter {
  AdjustAdapter({
    required this.config,
    AdjustClient? client,
  }) : _client = client ?? DefaultAdjustClient();

  final AdjustEventConfig config;
  final AdjustClient _client;

  @override
  EventPlatform get platform => EventPlatform.adjust;

  @override
  Future<void> init() async {
    if (!config.initSdk) return;

    final environment = config.isProduction
        ? AdjustEnvironment.production
        : AdjustEnvironment.sandbox;
    final adjustConfig = AdjustConfig(config.appToken, environment);
    _client.initSdk(adjustConfig);
  }

  @override
  Future<void> track(Event event) async {
    final token = config.eventTokens[event.name];
    if (token == null || token.isEmpty) {
      throw EventSdkException(
        'No Adjust event token mapped for "${event.name}". '
        'Add it to AdjustEventConfig.eventTokens.',
      );
    }

    final adjustEvent = AdjustEvent(token);
    event.props.forEach((key, value) {
      if (value == null) return;
      if (key == 'revenue' && event.props['currency'] != null) {
        final revenue = value is num ? value : num.tryParse(value.toString());
        final currency = event.props['currency']?.toString();
        if (revenue != null && currency != null) {
          adjustEvent.setRevenue(revenue, currency);
        }
        return;
      }
      if (key == 'currency') return;
      adjustEvent.addCallbackParameter(key, value.toString());
    });

    _client.trackEvent(adjustEvent);
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    // Adjust uses partner/callback params or third-party sharing APIs;
    // expose user id as a global callback parameter for Phase 1.
    _client.addGlobalCallbackParameter('user_id', userId);
    traits?.forEach((key, value) {
      if (value == null) return;
      _client.addGlobalCallbackParameter(key, value.toString());
    });
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {}
}

/// Console logging client for local demos / tests (no network).
class LoggingAdjustClient implements AdjustClient {
  @override
  void initSdk(AdjustConfig config) {}

  @override
  void trackEvent(AdjustEvent event) {
    // ignore: avoid_print
    print('[adjust] trackEvent ${event.toMap}');
  }

  @override
  void addGlobalCallbackParameter(String key, String value) {
    // ignore: avoid_print
    print('[adjust] global $key=$value');
  }
}
