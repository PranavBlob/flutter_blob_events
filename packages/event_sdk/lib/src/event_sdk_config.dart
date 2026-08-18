/// Global SDK behavior.
class EventSdkConfig {
  const EventSdkConfig({
    this.failSoft = true,
    this.onAdapterError,
    this.defaultParams = const {},
  });

  /// When true, one adapter failure does not fail [EventSdk.track].
  final bool failSoft;

  /// Optional hook for logging / crash reporting.
  final void Function(Object error, StackTrace stackTrace)? onAdapterError;

  /// Key/value pairs merged into every [EventSdk.track] call for **all**
  /// registered platforms (AWS, AWS endpoint, Adjust, Firebase, Amplitude).
  ///
  /// Per-event [EventSdk.track] props override keys with the same name.
  /// Edit these in `lib/event_sdk_config.dart` (`eventSdkDefaultParams`) and
  /// change them at runtime with [EventSdk.setDefaultParam].
  final Map<String, Object?> defaultParams;
}
