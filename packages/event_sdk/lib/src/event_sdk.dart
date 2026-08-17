import 'event.dart';
import 'event_adapter.dart';
import 'event_platform.dart';
import 'event_sdk_config.dart';
import 'event_sdk_exception.dart';

/// Single entrypoint for apps. Register adapters once, then call [track].
class EventSdk {
  EventSdk._();

  static final Map<EventPlatform, EventAdapter> _adapters = {};
  static final Set<EventPlatform> _disabled = {};
  static EventSdkConfig _config = const EventSdkConfig();
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static List<EventPlatform> get registeredPlatforms =>
      List.unmodifiable(_adapters.keys);

  static List<EventPlatform> get enabledPlatforms => _adapters.keys
      .where((p) => !_disabled.contains(p))
      .toList(growable: false);

  /// Registers and initializes adapters. Safe to call once per process.
  static Future<void> init(
    List<EventAdapter> adapters, {
    EventSdkConfig config = const EventSdkConfig(),
  }) async {
    if (adapters.isEmpty) {
      throw EventSdkException('init requires at least one adapter.');
    }

    final seen = <EventPlatform>{};
    for (final adapter in adapters) {
      if (!seen.add(adapter.platform)) {
        throw EventSdkException(
          'Duplicate adapter for ${adapter.platform.name}.',
        );
      }
    }

    _config = config;
    _adapters
      ..clear()
      ..addEntries(adapters.map((a) => MapEntry(a.platform, a)));
    _disabled.clear();

    for (final adapter in adapters) {
      await adapter.init();
    }
    _initialized = true;
  }

  static void enable(EventPlatform platform) {
    _ensureInitialized();
    _requireRegistered(platform);
    _disabled.remove(platform);
  }

  static void disable(EventPlatform platform) {
    _ensureInitialized();
    _requireRegistered(platform);
    _disabled.add(platform);
  }

  static Future<void> track(
    String name, {
    Map<String, Object?> props = const {},
    List<EventPlatform>? exclude,
    List<EventPlatform>? only,
    DateTime? timestamp,
  }) async {
    _ensureInitialized();
    if (name.trim().isEmpty) {
      throw EventSdkException('Event name must not be empty.');
    }
    if (exclude != null && only != null) {
      throw EventSdkException('Pass either exclude or only, not both.');
    }

    final targets = _resolveTargets(exclude: exclude, only: only);
    final event = Event(
      name: name,
      props: Map.unmodifiable(props),
      timestamp: timestamp ?? DateTime.now().toUtc(),
    );

    await Future.wait([
      for (final platform in targets)
        _runAdapter(platform, () => _adapters[platform]!.track(event)),
    ]);
  }

  static Future<void> identify(
    String userId, {
    Map<String, Object?>? traits,
  }) async {
    _ensureInitialized();
    if (userId.trim().isEmpty) {
      throw EventSdkException('userId must not be empty.');
    }

    await Future.wait([
      for (final platform in enabledPlatforms)
        _runAdapter(
          platform,
          () => _adapters[platform]!.identify(userId, traits: traits),
        ),
    ]);
  }

  static Future<void> flush() async {
    _ensureInitialized();
    await Future.wait([
      for (final platform in enabledPlatforms)
        _runAdapter(platform, () => _adapters[platform]!.flush()),
    ]);
  }

  static Future<void> dispose() async {
    if (!_initialized) return;
    for (final adapter in _adapters.values) {
      await adapter.dispose();
    }
    _adapters.clear();
    _disabled.clear();
    _initialized = false;
  }

  /// Test-only reset.
  static void debugReset() {
    _adapters.clear();
    _disabled.clear();
    _config = const EventSdkConfig();
    _initialized = false;
  }

  static List<EventPlatform> _resolveTargets({
    List<EventPlatform>? exclude,
    List<EventPlatform>? only,
  }) {
    final enabled = enabledPlatforms.toSet();

    if (only != null) {
      for (final platform in only) {
        _requireRegistered(platform);
      }
      return only.where(enabled.contains).toList(growable: false);
    }

    if (exclude != null) {
      for (final platform in exclude) {
        _requireRegistered(platform);
      }
      final excluded = exclude.toSet();
      return enabled.where((p) => !excluded.contains(p)).toList(growable: false);
    }

    return enabled.toList(growable: false);
  }

  static Future<void> _runAdapter(
    EventPlatform platform,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      _config.onAdapterError?.call(error, stackTrace);
      if (!_config.failSoft) {
        throw EventSdkException(
          'Adapter ${platform.name} failed: $error',
        );
      }
    }
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw EventSdkException(
        'EventSdk.init(...) must be called before use.',
      );
    }
  }

  static void _requireRegistered(EventPlatform platform) {
    if (!_adapters.containsKey(platform)) {
      throw EventSdkException(
        'Platform ${platform.name} is not registered. '
        'Add its package and pass the adapter to EventSdk.init.',
      );
    }
  }
}
