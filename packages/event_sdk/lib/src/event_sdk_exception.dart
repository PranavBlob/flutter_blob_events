/// Thrown for invalid SDK usage (not for per-adapter transport errors).
class EventSdkException implements Exception {
  EventSdkException(this.message);

  final String message;

  @override
  String toString() => 'EventSdkException: $message';
}
