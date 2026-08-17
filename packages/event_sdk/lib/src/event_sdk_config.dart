/// Global SDK behavior.
class EventSdkConfig {
  const EventSdkConfig({
    this.failSoft = true,
    this.onAdapterError,
  });

  /// When true, one adapter failure does not fail [EventSdk.track].
  final bool failSoft;

  /// Optional hook for logging / crash reporting.
  final void Function(Object error, StackTrace stackTrace)? onAdapterError;
}
