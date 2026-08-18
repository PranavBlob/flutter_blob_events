# Demo app testing guide

End-to-end steps to test Event SDK in a **new Flutter app** using the CLI.

**Repo:** https://github.com/PranavBlob/flutter_blob_events  
**Branch:** `event_sdk`

---

## What you will verify

- CLI installs and runs
- Git dependencies resolve
- Generated setup + app config files are created
- Android/iOS native requirements are added automatically
- SDK initializes and fires events
- `exclude` / `only` routing works
- Optional: events appear in vendor dashboards

---

## Prerequisites

- Flutter 3.38+ / Dart 3.10+
- Git access to the repo above
- Android emulator/device and/or iOS simulator/device
- Vendor credentials (for real dashboard testing):
  - AWS Pinpoint / Amplify config
  - Adjust app token + event tokens
  - Firebase project (if testing Firebase)
  - Amplitude API key (if testing Amplitude)

---

## Step 1 — Create a new demo app

```bash
flutter create event_sdk_demo
cd event_sdk_demo
```

---

## Step 2 — Install Event SDK CLI (once per machine)

```bash
dart pub global activate --source git \
  https://github.com/PranavBlob/flutter_blob_events.git \
  --git-path packages/event_sdk_cli \
  --git-ref event_sdk
```

If `event_sdk` is not found, add Dart global bin to your PATH (often `~/.pub-cache/bin`) and open a new terminal.

Verify:

```bash
event_sdk list
```

---

## Step 3 — Initialize SDK in the demo app

### Option A — Test all 4 platforms

```bash
event_sdk init --platforms aws,adjust,firebase,amplitude
```

### Option B — Start with AWS + Adjust only (easier first test)

```bash
event_sdk init --platforms aws,adjust
```

The CLI will:

1. Add git dependencies to `pubspec.yaml`
2. Create `lib/generated/event_sdk_setup.g.dart` (generated — do not edit)
3. Create `lib/event_sdk_config.dart` (your credentials — edit TODOs)
4. Add Android `INTERNET` permission
5. Add iOS `NSUserTrackingUsageDescription` when Adjust is enabled

Then:

```bash
flutter pub get
```

---

## Step 4 — Fix common `flutter pub get` error

If you see:

```text
event_sdk_amplitude from git depends on event_sdk from hosted ...
version solving failed
```

Make sure you are on the latest `event_sdk` branch (includes commit `8ef4e74` or newer), then:

```bash
flutter clean
rm -rf pubspec.lock .dart_tool
flutter pub get
```

---

## Step 5 — Fill credentials

Open:

```text
lib/event_sdk_config.dart
```

Replace all `REPLACE_WITH_*` placeholders.

| Platform | What to fill |
|---|---|
| AWS | `AwsPinpointConfig.amplifyConfig` |
| Adjust | `appToken` + `eventTokens` map |
| Amplitude | `AmplitudeConfig.apiKey` |
| Firebase | No secret in config file (see Step 6) |

**Adjust note:** every event name you call via `EventSdk.track(...)` must exist in `eventTokens`.

Platform details:

- [AWS Pinpoint](platforms/aws_pinpoint.md)
- [Adjust](platforms/adjust.md)
- [Firebase](platforms/firebase.md)
- [Amplitude](platforms/amplitude.md)

---

## Step 6 — Firebase setup (only if Firebase is enabled)

Event SDK does **not** generate `firebase_options.dart`. You must run FlutterFire in the demo app.

```bash
flutter pub add firebase_core
dart pub global activate flutterfire_cli
flutterfire configure
```

This creates:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

If you see:

```text
DefaultFirebaseOptions not found
import 'firebase_options.dart' gives error
```

It means Step 6 was not completed yet.

---

## Step 7 — Wire `main.dart`

### If Firebase is enabled

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'generated/event_sdk_setup.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupEventSdk();
  runApp(const MyApp());
}
```

### If Firebase is NOT enabled

```dart
import 'package:flutter/material.dart';
import 'generated/event_sdk_setup.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupEventSdk();
  runApp(const MyApp());
}
```

---

## Step 8 — Add a simple test UI

Replace `lib/main.dart` body with buttons that call the SDK:

```dart
import 'package:flutter/material.dart';
import 'package:event_sdk/event_sdk.dart';
import 'generated/event_sdk_setup.g.dart';

// Include Firebase imports/init from Step 7 if Firebase is enabled.

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  Future<void> _trackSignup() async {
    await EventSdk.track(
      'signup',
      props: {'method': 'email', 'plan': 'free'},
    );
  }

  Future<void> _trackPurchase() async {
    await EventSdk.track(
      'purchase',
      props: {'revenue': 9.99, 'currency': 'USD'},
    );
  }

  Future<void> _trackOnlyAws() async {
    await EventSdk.track(
      'screen_view',
      props: {'screen': 'home'},
      only: [EventPlatform.aws],
    );
  }

  Future<void> _trackExcludeAdjust() async {
    await EventSdk.track(
      'screen_view',
      props: {'screen': 'profile'},
      exclude: [EventPlatform.adjust],
    );
  }

  Future<void> _identifyUser() async {
    await EventSdk.identify(
      'user_123',
      traits: {'plan': 'pro'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event SDK Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(onPressed: _trackSignup, child: const Text('Track Signup')),
          ElevatedButton(onPressed: _trackPurchase, child: const Text('Track Purchase')),
          ElevatedButton(onPressed: _trackOnlyAws, child: const Text('Track Only AWS')),
          ElevatedButton(
            onPressed: _trackExcludeAdjust,
            child: const Text('Track Exclude Adjust'),
          ),
          ElevatedButton(onPressed: _identifyUser, child: const Text('Identify User')),
        ],
      ),
    );
  }
}
```

---

## Step 9 — Run doctor

```bash
event_sdk doctor
```

Doctor checks:

- setup/config files exist
- credential placeholders still unfilled
- Firebase init reminder (if enabled)
- Android INTERNET permission
- iOS ATT string for Adjust

Fix reported items, then continue.

---

## Step 10 — Run on Android

```bash
flutter run
```

Verify Android manifest contains internet permission:

```text
android/app/src/main/AndroidManifest.xml
```

Expected:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Tap all test buttons.

---

## Step 11 — Run on iOS

```bash
cd ios
pod install
cd ..
flutter run
```

If Adjust is enabled, verify:

```text
ios/Runner/Info.plist
```

Contains:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>...</string>
```

Tap all test buttons on iOS too.

---

## Step 12 — Validate routing behavior

| Button | Expected |
|---|---|
| Track Signup | All enabled platforms receive event |
| Track Purchase | All enabled platforms receive purchase props |
| Track Only AWS | Only AWS/Pinpoint |
| Track Exclude Adjust | All except Adjust |
| Identify User | User traits sent to enabled platforms |

---

## Step 13 — Validate in dashboards (optional)

Check each enabled vendor dashboard for your test events:

- AWS Pinpoint: `signup`, `purchase`, `screen_view`
- Adjust: only mapped token events
- Firebase: DebugView / Realtime
- Amplitude: Live events stream

---

## Step 14 — Test add-platform-later flow

Start with AWS + Adjust, then add more without changing feature code:

```bash
event_sdk add --platforms firebase,amplitude
flutter pub get
```

Then:

1. Complete Firebase setup (Step 6) if needed
2. Fill new placeholders in `lib/event_sdk_config.dart`
3. Re-run app
4. Existing `EventSdk.track(...)` calls should still work unchanged

---

## Step 15 — Test remove-platform flow

```bash
event_sdk remove --platforms adjust
flutter pub get
event_sdk doctor
```

Adjust should be removed from deps/config while other platforms remain.

---

## Troubleshooting

### `event_sdk` command not found

```bash
dart pub global activate --source git \
  https://github.com/PranavBlob/flutter_blob_events.git \
  --git-path packages/event_sdk_cli \
  --git-ref event_sdk
```

Add `~/.pub-cache/bin` to PATH.

### `firebase_options.dart` missing

Run:

```bash
flutterfire configure
```

Do not import Firebase init code until that file exists.

### Adjust events not appearing

- Confirm event name exists in `eventTokens`
- Confirm Adjust app token is correct
- Use sandbox token/environment for dev testing

### AWS events not appearing

- Confirm Amplify/Pinpoint config string is valid
- Confirm Pinpoint analytics is enabled in Amplify backend

### iOS build issues after adding plugins

```bash
cd ios
pod repo update
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## Final checklist

- [ ] Demo app created
- [ ] CLI installed
- [ ] `event_sdk init` completed
- [ ] `flutter pub get` succeeds
- [ ] `lib/event_sdk_config.dart` placeholders filled
- [ ] Firebase configured (if enabled)
- [ ] `event_sdk doctor` passes (or only expected warnings remain)
- [ ] App runs on Android
- [ ] App runs on iOS
- [ ] Track / exclude / only buttons tested
- [ ] Dashboard events verified (optional)
- [ ] `add` / `remove` platform flow tested (optional)

---

## Related docs

- [CLI reference](cli.md)
- [Getting started](getting_started.md)
- [Usage & API](usage.md)
- [Integration guide](integration.md)
