# Usage & API

All app feature code should use **`package:event_sdk/event_sdk.dart`** only.

## Lifecycle

```dart
await EventSdk.init([...adapters], config: EventSdkConfig(...));

await EventSdk.track('event_name', props: {...});
await EventSdk.identify('user_123', traits: {...});
await EventSdk.flush();

EventSdk.disable(EventPlatform.adjust);
EventSdk.enable(EventPlatform.adjust);

await EventSdk.dispose(); // optional shutdown
```

`init` must run once before any `track` / `identify` / `flush`.

---

## `EventSdk.init`

```dart
await EventSdk.init(
  [
    AwsPinpointAdapter(config: ...),
    AdjustAdapter(config: ...),
  ],
  config: const EventSdkConfig(
    failSoft: true, // default: one adapter failure won't fail the whole track
    defaultParams: {'source': 'mobile_app'},
  ),
);
```

Rules:

- At least one adapter required
- Duplicate platforms rejected
- Each adapter’s `init()` runs during SDK init

---

## Default params (all platforms)

Key/value pairs merged into **every** `EventSdk.track` call **before** adapters
run. AWS Pinpoint, AWS HTTP endpoint, Adjust, Firebase, and Amplitude all
receive the same merged props.

Per-event `props` override keys with the same name.

### Edit in `lib/event_sdk_config.dart` (CLI apps)

This file is app-owned. Add or change keys here; they apply to all platforms:

```dart
final eventSdkDefaultParams = <String, Object?>{
  'source': 'mobile_app',
  'env': 'dev',
};

EventSdkConfig createEventSdkConfig() => EventSdkConfig(
  defaultParams: eventSdkDefaultParams,
);
```

`setupEventSdk()` passes this into `EventSdk.init`.

### At runtime (after login, plan change, etc.)

```dart
EventSdk.setDefaultParam('userId', 'user_123');
EventSdk.setDefaultParam('userType', 'premium');
EventSdk.updateDefaultParams({'plan': 'pro'});
EventSdk.removeDefaultParams(['temp_flag']);
EventSdk.setDefaultParam('userId', null); // removes the key
```

```dart
await EventSdk.track('signup', props: {'method': 'email'});
// every enabled platform receives: source, env, userId, userType, method
```

On `aws_endpoint_sdk`, merged props are sent in the HTTP `parameters` field.

---

## `EventSdk.track`

```dart
await EventSdk.track(
  String name, {
  Map<String, Object?> props = const {},
  List<EventPlatform>? exclude,
  List<EventPlatform>? only,
  DateTime? timestamp, // defaults to DateTime.now().toUtc()
});
```

### Default — all enabled platforms

```dart
await EventSdk.track('button_tap', props: {'id': 'cta_primary'});
```

### `exclude` — skip platforms for this event

```dart
await EventSdk.track(
  'debug_ping',
  exclude: [EventPlatform.adjust],
);
```

### `only` — restrict to listed platforms

```dart
await EventSdk.track(
  'pinpoint_only_metric',
  only: [EventPlatform.aws],
);
```

### Invalid

```dart
// Throws EventSdkException
await EventSdk.track(
  'x',
  exclude: [EventPlatform.aws],
  only: [EventPlatform.adjust],
);
```

### Property types

Prefer primitives that adapters can map cleanly:

| Type | Notes |
|---|---|
| `String` | Always safe |
| `bool` | Supported on Pinpoint |
| `int` / `double` | Supported on Pinpoint; Adjust sends callback params as strings |
| `null` | Ignored |

Special Adjust props for revenue events: `revenue` + `currency` (see [Adjust](platforms/adjust.md)).

---

## `EventSdk.identify`

```dart
await EventSdk.identify(
  'user_123',
  traits: {
    'plan': 'pro',
    'email': 'a@b.com',
  },
);
```

Sent to all **enabled** registered platforms.

---

## `EventSdk.flush`

```dart
await EventSdk.flush();
```

Asks adapters to flush buffered events (Pinpoint supports this; Adjust no-op in Phase 1).

---

## Enable / disable at runtime

Registered ≠ enabled.

```dart
EventSdk.disable(EventPlatform.adjust); // consent off / kill switch
await EventSdk.track('signup');         // AWS only

EventSdk.enable(EventPlatform.adjust);
await EventSdk.track('signup');         // AWS + Adjust
```

This does **not** remove the package from `pubspec`. To permanently drop a platform, remove the dependency (or use CLI `remove`).

---

## Error behavior

| Setting | Behavior |
|---|---|
| `failSoft: true` (default) | Adapter errors are swallowed; other adapters still run |
| `failSoft: false` | First adapter failure throws `EventSdkException` |
| `onAdapterError` | Optional callback for logging |

```dart
EventSdkConfig(
  failSoft: true,
  onAdapterError: (error, stack) {
    // log / report
  },
);
```

---

## Platforms enum

```dart
enum EventPlatform {
  aws,          // Pinpoint — event_sdk_aws
  awsEndpoint,  // HTTP events API — aws_endpoint_sdk
  adjust,
  firebase,
  amplitude,
}
```

`EventPlatform.aws` and `EventPlatform.awsEndpoint` are different platforms. Use `awsEndpoint` with `only` / `exclude` when you initialized `aws_endpoint_sdk`.

---

## What feature code should NOT do

- Import `amplify_flutter` / `adjust_sdk` from feature modules
- Call vendor SDKs directly for product analytics
- Branch on platform inside UI code — use `exclude` / `only` or runtime disable instead

Keep vendor details inside setup + adapter packages.
