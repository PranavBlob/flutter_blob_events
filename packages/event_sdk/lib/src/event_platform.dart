/// Supported analytics / attribution platforms.
enum EventPlatform {
  /// Amazon Pinpoint (`event_sdk_aws`).
  aws,

  /// Custom AWS HTTP events endpoint (`aws_endpoint_sdk`).
  /// Use this with `only` / `exclude` — not [aws].
  awsEndpoint,

  /// Adjust (`event_sdk_adjust`).
  adjust,

  /// Firebase Analytics (`event_sdk_firebase`).
  firebase,

  /// Amplitude (`event_sdk_amplitude`).
  amplitude,
}
