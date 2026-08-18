# Adjust platform (`event_sdk_adjust`)

Sends events through the **Adjust** Flutter SDK.

## Dependency

```yaml
event_sdk_adjust:
  git:
    url: https://github.com/PranavBlob/flutter_blob_events.git
    path: packages/event_sdk_adjust
    ref: event_sdk
```

Also depend on `event_sdk` and add a `dependency_overrides` entry for it using
the same git url/path/ref. Pub will fail without that override. The CLI writes
it automatically. See [Getting started](../getting_started.md).

## Config — `AdjustEventConfig`

```dart
AdjustEventConfig({
  required String appToken,              // Adjust app token
  bool isProduction = false,             // false = sandbox
  Map<String, String> eventTokens = {},  // logical name → Adjust event token
  bool initSdk = true,                   // false if app already called Adjust.initSdk
})
```

### Example

```dart
import 'package:event_sdk_adjust/event_sdk_adjust.dart';

AdjustAdapter(
  config: AdjustEventConfig(
    appToken: 'YOUR_APP_TOKEN',
    isProduction: false,
    eventTokens: {
      'app_open': 'abc123',
      'signup': 'def456',
      'purchase': 'ghi789',
    },
  ),
)
```

## Event name → token map (required)

Adjust tracks **event tokens**, not free-form names.

When you call:

```dart
await EventSdk.track('signup', props: {'method': 'email'});
```

the adapter looks up `eventTokens['signup']`.  
If missing, it throws `EventSdkException` (failSoft may swallow it depending on core config).

Keep your map in sync with the Adjust dashboard.

## Props

| Prop | Behavior |
|---|---|
| `revenue` + `currency` | Calls `AdjustEvent.setRevenue` |
| other keys | Added as callback parameters (stringified) |
| `currency` alone | Ignored unless paired with `revenue` |

```dart
await EventSdk.track(
  'purchase',
  props: {
    'revenue': 9.99,
    'currency': 'USD',
    'sku': 'pro_monthly',
  },
);
```

## Identify

Phase 1 maps `identify` to Adjust global callback parameters (`user_id` + traits). Refine later if you need Adjust-specific user APIs.

## Local demo without Adjust network

```dart
AdjustAdapter(
  config: const AdjustEventConfig(
    appToken: 'DEMO',
    initSdk: false,
    eventTokens: {'button_tap': 'demo_token'},
  ),
  client: LoggingAdjustClient(),
)
```

## Platform project notes

Follow Adjust’s Flutter install steps for iOS/Android (ATT / permissions as required for your app store compliance). Those native settings live in the **host app**, not in `event_sdk_adjust`.
