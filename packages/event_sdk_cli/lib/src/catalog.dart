/// Known platforms and package paths inside the monorepo.
class PlatformSpec {
  const PlatformSpec({
    required this.id,
    required this.packageName,
    required this.packagePath,
    required this.importUri,
    required this.adapterExpression,
    required this.available,
  });

  final String id;
  final String packageName;
  final String packagePath;
  final String importUri;

  /// Snippet used inside generated setup (config filled by app).
  final String adapterExpression;
  final bool available;
}

const supportedPlatforms = <String, PlatformSpec>{
  'aws': PlatformSpec(
    id: 'aws',
    packageName: 'event_sdk_aws',
    packagePath: 'packages/event_sdk_aws',
    importUri: 'package:event_sdk_aws/event_sdk_aws.dart',
    adapterExpression:
        'AwsPinpointAdapter(config: /* TODO: AwsPinpointConfig(...) */ throw UnimplementedError("Configure AwsPinpointConfig"))',
    available: true,
  ),
  'adjust': PlatformSpec(
    id: 'adjust',
    packageName: 'event_sdk_adjust',
    packagePath: 'packages/event_sdk_adjust',
    importUri: 'package:event_sdk_adjust/event_sdk_adjust.dart',
    adapterExpression:
        'AdjustAdapter(config: /* TODO: AdjustEventConfig(...) */ throw UnimplementedError("Configure AdjustEventConfig"))',
    available: true,
  ),
  'firebase': PlatformSpec(
    id: 'firebase',
    packageName: 'event_sdk_firebase',
    packagePath: 'packages/event_sdk_firebase',
    importUri: 'package:event_sdk_firebase/event_sdk_firebase.dart',
    adapterExpression: 'FirebaseAnalyticsAdapter()',
    available: true,
  ),
  'amplitude': PlatformSpec(
    id: 'amplitude',
    packageName: 'event_sdk_amplitude',
    packagePath: 'packages/event_sdk_amplitude',
    importUri: 'package:event_sdk_amplitude/event_sdk_amplitude.dart',
    adapterExpression:
        'AmplitudeAdapter(config: /* TODO: AmplitudeConfig(apiKey: ...) */ throw UnimplementedError("Configure AmplitudeConfig"))',
    available: true,
  ),
};

List<PlatformSpec> resolvePlatforms(List<String> ids) {
  final out = <PlatformSpec>[];
  for (final raw in ids) {
    final id = raw.trim().toLowerCase();
    if (id.isEmpty) continue;
    final spec = supportedPlatforms[id];
    if (spec == null) {
      throw ArgumentError('Unknown platform "$raw".');
    }
    if (!spec.available) {
      throw ArgumentError(
        'Platform "$id" is not available yet (planned for a later phase).',
      );
    }
    out.add(spec);
  }
  if (out.isEmpty) {
    throw ArgumentError('Provide at least one platform.');
  }
  return out;
}
