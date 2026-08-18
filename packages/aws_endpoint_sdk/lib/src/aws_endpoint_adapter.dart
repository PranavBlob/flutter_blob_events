import 'package:event_sdk/event_sdk.dart';

import 'aws_endpoint_client.dart';
import 'aws_endpoint_config.dart';

/// Sends events to a custom AWS analytics HTTP endpoint using the
/// MobileTrackingEvent JSON format (aligned with iOS AWSAnalyticsDispatcher).
class AwsEndpointAdapter implements EventAdapter {
  AwsEndpointAdapter({
    required this.config,
    AwsEndpointClient? client,
  }) : _client = client ?? HttpAwsEndpointClient(),
       _defaultFields = config.defaultFields,
       _adjustAttribution = Map<String, String>.from(config.adjustAttribution);

  final AwsEndpointConfig config;
  final AwsEndpointClient _client;

  AwsEndpointDefaultFields _defaultFields;
  Map<String, String> _adjustAttribution;

  @override
  EventPlatform get platform => EventPlatform.awsEndpoint;

  @override
  Future<void> init() async {}

  /// Updates top-level payload fields (device/user metadata).
  void updateDefaultFields(AwsEndpointDefaultFields fields) {
    _defaultFields = fields;
  }

  /// Merges Adjust attribution into the top-level payload.
  void setAdjustAttribution(Map<String, String>? attribution) {
    _adjustAttribution = attribution == null
        ? Map<String, String>.from(config.adjustAttribution)
        : Map<String, String>.from(attribution);
  }

  @override
  Future<void> track(Event event) async {
    final endpoint = config.endpoint.trim();
    if (endpoint.isEmpty) return;

    final body = <String, dynamic>{
      'ename': event.name,
      ..._defaultFields.toPayloadMap(),
      if (_adjustAttribution.isNotEmpty) ..._adjustAttribution,
      'stream': config.stream,
      'parameters': _stringifyValues(event.props),
    };

    await postEventSafely(
      client: _client,
      endpoint: endpoint,
      body: body,
      eventName: event.name,
    );
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    _defaultFields = _defaultFields.copyWith(userId: userId);
    if (traits == null || traits.isEmpty) return;

    final extra = Map<String, String>.from(_defaultFields.extra);
    traits.forEach((key, value) {
      if (value == null) return;
      extra[key] = value.toString();
    });
    _defaultFields = _defaultFields.copyWith(extra: extra);
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {}

  Map<String, String> _stringifyValues(Map<String, Object?> props) {
    return {
      for (final entry in props.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
  }
}
