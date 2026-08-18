# Getting started

This guide gets Event SDK running in a Flutter app with **AWS Pinpoint** and **Adjust**.

## Prerequisites

- Flutter 3.38+ / Dart 3.10+
- An Amplify / Pinpoint analytics config (or plan to use logging clients first)
- An Adjust app token + event tokens from the Adjust dashboard

## Step 1 — Add dependencies

Only add platforms you need now:

```yaml
dependencies:
  event_sdk:
    git:
      url: https://github.com/PranavBlob/flutter_blob_events.git
      path: packages/event_sdk
      ref: event_sdk
  event_sdk_aws:
    git:
      url: https://github.com/PranavBlob/flutter_blob_events.git
      path: packages/event_sdk_aws
      ref: event_sdk
  event_sdk_adjust:
    git:
      url: https://github.com/PranavBlob/flutter_blob_events.git
      path: packages/event_sdk_adjust
      ref: event_sdk
```

Then:

```bash
flutter pub get
```

> Prefer the one-command installer? See [cli.md](cli.md)
> (`event_sdk init --platforms aws,adjust`).

## Step 2 — Initialize via CLI (recommended)

From your Flutter app root:

```bash
event_sdk init --platforms aws,adjust
```

This creates:
- `lib/generated/event_sdk_setup.g.dart` (generated — do not edit)
- `lib/event_sdk_config.dart` (app-owned config — edit the TODOs)

Then run:

```bash
flutter pub get
```

### Fill credentials (only manual step)

Open `lib/event_sdk_config.dart` and replace the placeholders, e.g.
- AWS Pinpoint: `AwsPinpointConfig.amplifyConfig`
- Adjust: `AdjustEventConfig.appToken` and `eventTokens` map

After that, the generated `setupEventSdk()` calls:

```dart
await EventSdk.init(createEventSdkAdapters());
```

Platform details:

- [AWS Pinpoint](platforms/aws_pinpoint.md)
- [Adjust](platforms/adjust.md)

## Step 3 — Call setup from `main`

```dart
import 'package:flutter/material.dart';
import 'generated/event_sdk_setup.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupEventSdk();
  runApp(const MyApp());
}
```

## Manual setup (alternative: no CLI)

If you don’t want to use the CLI, you can manually implement
`setupEventSdk()` by calling `EventSdk.init([...adapters...])` in any file.

## Step 4 — Track events in features

```dart
import 'package:event_sdk/event_sdk.dart';

Future<void> onSignupSuccess() async {
  await EventSdk.track(
    'signup',
    props: {
      'method': 'email',
      'plan': 'free',
    },
  );
}

Future<void> onPurchase(double amount) async {
  await EventSdk.track(
    'purchase',
    props: {
      'revenue': amount,
      'currency': 'USD',
    },
  );
}
```

That’s it for day-1 integration. Feature code only imports `event_sdk` — not AWS or Adjust SDKs.

## Step 5 — Optional per-event targeting

```dart
// Default: all enabled platforms
await EventSdk.track('screen_view', props: {'name': 'Home'});

// Skip one platform
await EventSdk.track(
  'screen_view',
  props: {'name': 'Home'},
  exclude: [EventPlatform.adjust],
);

// Fire only one platform
await EventSdk.track(
  'screen_view',
  props: {'name': 'Home'},
  only: [EventPlatform.aws],
);
```

Do **not** pass both `exclude` and `only` — the SDK throws.

## Try the example app

From this repo:

```bash
cd examples/event_sdk_example
flutter run
```

The example uses **logging clients** (prints to console) so you can exercise the API without real Pinpoint/Adjust credentials. See [example README](../examples/event_sdk_example/README.md).

## Next

- Full API: [usage.md](usage.md)
- Add Firebase/Amplitude later: [cli.md](cli.md)
- Architecture: [architecture.md](architecture.md)
