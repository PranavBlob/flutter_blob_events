import 'event.dart';
import 'event_platform.dart';

/// Contract implemented by each platform package (`event_sdk_aws`, …).
abstract class EventAdapter {
  EventPlatform get platform;

  Future<void> init();

  Future<void> track(Event event);

  Future<void> identify(String userId, {Map<String, Object?>? traits}) {
    return Future<void>.value();
  }

  Future<void> flush() => Future<void>.value();

  Future<void> dispose() => Future<void>.value();
}
