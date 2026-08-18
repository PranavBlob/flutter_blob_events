# Amplitude (`event_sdk_amplitude`)

Routes `EventSdk.track` calls to the official Amplitude Flutter SDK.

## Add the package

```yaml
dependencies:
  event_sdk_amplitude:
    git:
      url: https://github.com/PranavBlob/flutter_blob_events.git
      path: packages/event_sdk_amplitude
      ref: event_sdk
```

Also depend on `event_sdk` and add a `dependency_overrides` entry for it using
the same git url/path/ref. See [Getting started](../getting_started.md).

## Configure

Create an Amplitude project, copy its API key, then register the adapter:

```dart
await EventSdk.init([
  AmplitudeAdapter(
    config: AmplitudeConfig(
      apiKey: 'YOUR_AMPLITUDE_API_KEY',
      // Optional: isolates identity/storage from the default instance.
      instanceName: 'product_analytics',
    ),
  ),
]);
```

`EventSdk.init` waits for the Amplitude client to initialize.

## Mapping

| Event SDK | Amplitude |
|---|---|
| Event name | `BaseEvent.eventType` |
| `props` | `BaseEvent.eventProperties` |
| Event timestamp | Epoch milliseconds |
| `identify(userId, traits)` | `setUserId` + Amplitude `Identify.set` |
| `flush()` | Amplitude `flush()` |

Example:

```dart
await EventSdk.track(
  'signup_completed',
  props: {'method': 'email', 'plan': 'free'},
);
```

Amplitude batches events locally and uploads them periodically; call
`EventSdk.flush()` when you need to request an immediate upload.
