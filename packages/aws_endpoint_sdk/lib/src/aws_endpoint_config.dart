/// Top-level MobileTrackingEvent fields sent with every HTTP request.
class AwsEndpointDefaultFields {
  const AwsEndpointDefaultFields({
    this.appName = '',
    this.platform = '',
    this.appId = '',
    this.deviceId = '',
    this.installId = '',
    this.userId = '',
    this.appVersion = '',
    this.appEnvironment = '',
    this.osVersion = '',
    this.deviceModel = '',
    this.languageCode = '',
    this.userType = '',
    this.gaid = '',
    this.extra = const {},
  });

  final String appName;
  final String platform;
  final String appId;
  final String deviceId;
  final String installId;
  final String userId;
  final String appVersion;
  final String appEnvironment;
  final String osVersion;
  final String deviceModel;
  final String languageCode;
  final String userType;
  final String gaid;

  /// Additional top-level JSON fields (e.g. attribution keys).
  final Map<String, String> extra;

  AwsEndpointDefaultFields copyWith({
    String? appName,
    String? platform,
    String? appId,
    String? deviceId,
    String? installId,
    String? userId,
    String? appVersion,
    String? appEnvironment,
    String? osVersion,
    String? deviceModel,
    String? languageCode,
    String? userType,
    String? gaid,
    Map<String, String>? extra,
  }) {
    return AwsEndpointDefaultFields(
      appName: appName ?? this.appName,
      platform: platform ?? this.platform,
      appId: appId ?? this.appId,
      deviceId: deviceId ?? this.deviceId,
      installId: installId ?? this.installId,
      userId: userId ?? this.userId,
      appVersion: appVersion ?? this.appVersion,
      appEnvironment: appEnvironment ?? this.appEnvironment,
      osVersion: osVersion ?? this.osVersion,
      deviceModel: deviceModel ?? this.deviceModel,
      languageCode: languageCode ?? this.languageCode,
      userType: userType ?? this.userType,
      gaid: gaid ?? this.gaid,
      extra: extra ?? this.extra,
    );
  }

  Map<String, String> toPayloadMap() {
    return {
      'app': appName,
      'os': platform,
      'appId': appId,
      'deviceId': deviceId,
      'installId': installId,
      'userId': userId,
      'appVersion': appVersion,
      'appEnvironment': appEnvironment,
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'languageCode': languageCode,
      'userType': userType,
      'gaid': gaid,
      ...extra,
    };
  }
}

/// Config for [AwsEndpointAdapter].
class AwsEndpointConfig {
  const AwsEndpointConfig({
    required this.endpoint,
    this.defaultFields = const AwsEndpointDefaultFields(),
    this.stream = 'mobile-tracking-event',
    this.adjustAttribution = const {},
  });

  /// Full URL, e.g. `https://dev-events.atomapplications.com/api/dev/v1`.
  final String endpoint;

  /// Top-level payload fields included on every event.
  final AwsEndpointDefaultFields defaultFields;

  /// Stream name sent as `stream` in the JSON body.
  final String stream;

  /// Optional Adjust attribution fields merged at the top level.
  final Map<String, String> adjustAttribution;
}
