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

> Prefer CLI? See [cli.md](cli.md) (`event_sdk_cli init --platforms aws,adjust`).

## Step 2 — Create a setup file

Create `lib/generated/event_sdk_setup.g.dart` (CLI generates this path by default):

```dart
import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_aws/event_sdk_aws.dart';
import 'package:event_sdk_adjust/event_sdk_adjust.dart';

// Import your Amplify config string, e.g.:
// import 'amplifyconfiguration.dart';

Future<void> setupEventSdk() async {
  await EventSdk.init(
    [
      AwsPinpointAdapter(
        config: AwsPinpointConfig(
          amplifyConfig: amplifyconfig,
          configureAmplify: true,
          addAuthPlugin: true,
        ),
      ),
      AdjustAdapter(
        config: AdjustEventConfig(
          appToken: 'YOUR_ADJUST_APP_TOKEN',
          isProduction: false,
          eventTokens: {
            'app_open': 'TOKEN_1',
            'signup': 'TOKEN_2',
            'purchase': 'TOKEN_3',
          },
        ),
      ),
    ],
    config: EventSdkConfig(
      failSoft: true,
      onAdapterError: (error, stack) {
        // Hook your logger / Crashlytics here
        // debugPrint('$error\n$stack');
      },
    ),
  );
}
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
