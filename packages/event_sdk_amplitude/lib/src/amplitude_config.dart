/// Dart configuration for the Amplitude adapter.
class AmplitudeConfig {
  const AmplitudeConfig({required this.apiKey, this.instanceName});

  /// Amplitude project's API key.
  final String apiKey;

  /// Optional named Amplitude instance. Omit to use the default instance.
  final String? instanceName;
}
