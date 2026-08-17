import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:event_sdk/event_sdk.dart';

import 'aws_pinpoint_config.dart';

/// Optional seam for tests / custom Pinpoint clients.
abstract class PinpointAnalyticsClient {
  Future<void> recordEvent(Event event);
  Future<void> identifyUser(String userId, {Map<String, Object?>? traits});
  Future<void> flushEvents();
}

class AmplifyPinpointAnalyticsClient implements PinpointAnalyticsClient {
  @override
  Future<void> recordEvent(Event event) async {
    final analyticsEvent = AnalyticsEvent(event.name);
    event.props.forEach((key, value) {
      if (value == null) return;
      if (value is String) {
        analyticsEvent.customProperties.addStringProperty(key, value);
      } else if (value is bool) {
        analyticsEvent.customProperties.addBoolProperty(key, value);
      } else if (value is int) {
        analyticsEvent.customProperties.addIntProperty(key, value);
      } else if (value is double) {
        analyticsEvent.customProperties.addDoubleProperty(key, value);
      } else {
        analyticsEvent.customProperties.addStringProperty(key, value.toString());
      }
    });
    await Amplify.Analytics.recordEvent(event: analyticsEvent);
  }

  @override
  Future<void> identifyUser(
    String userId, {
    Map<String, Object?>? traits,
  }) async {
    final profile = AWSPinpointUserProfile(
      customProperties: _propertiesFromTraits(traits),
    );
    await Amplify.Analytics.identifyUser(userId: userId, userProfile: profile);
  }

  @override
  Future<void> flushEvents() => Amplify.Analytics.flushEvents();

  CustomProperties? _propertiesFromTraits(Map<String, Object?>? traits) {
    if (traits == null || traits.isEmpty) return null;
    final props = CustomProperties();
    traits.forEach((key, value) {
      if (value == null) return;
      if (value is String) {
        props.addStringProperty(key, value);
      } else if (value is bool) {
        props.addBoolProperty(key, value);
      } else if (value is int) {
        props.addIntProperty(key, value);
      } else if (value is double) {
        props.addDoubleProperty(key, value);
      } else {
        props.addStringProperty(key, value.toString());
      }
    });
    return props;
  }
}

/// Amazon Pinpoint adapter for [EventSdk].
class AwsPinpointAdapter implements EventAdapter {
  AwsPinpointAdapter({
    required this.config,
    PinpointAnalyticsClient? client,
  }) : _client = client ?? AmplifyPinpointAnalyticsClient();

  final AwsPinpointConfig config;
  final PinpointAnalyticsClient _client;

  @override
  EventPlatform get platform => EventPlatform.aws;

  @override
  Future<void> init() async {
    if (!config.configureAmplify) return;
    if (Amplify.isConfigured) return;

    final plugins = <AmplifyPluginInterface>[
      AmplifyAnalyticsPinpoint(),
      if (config.addAuthPlugin) AmplifyAuthCognito(),
    ];
    await Amplify.addPlugins(plugins);
    await Amplify.configure(config.amplifyConfig);
  }

  @override
  Future<void> track(Event event) => _client.recordEvent(event);

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) {
    return _client.identifyUser(userId, traits: traits);
  }

  @override
  Future<void> flush() => _client.flushEvents();

  @override
  Future<void> dispose() async {}
}

/// Console logging client for local demos / tests (no network).
class LoggingPinpointClient implements PinpointAnalyticsClient {
  @override
  Future<void> recordEvent(Event event) async {
    // ignore: avoid_print
    print('[pinpoint] ${event.name} ${event.props}');
  }

  @override
  Future<void> identifyUser(String userId, {Map<String, Object?>? traits}) async {
    // ignore: avoid_print
    print('[pinpoint] identify $userId $traits');
  }

  @override
  Future<void> flushEvents() async {
    // ignore: avoid_print
    print('[pinpoint] flush');
  }
}
