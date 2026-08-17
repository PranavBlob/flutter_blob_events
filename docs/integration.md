# Integration guide

Two ways to wire Event SDK into an app:

1. **Manual** — edit `pubspec.yaml` + write setup yourself  
2. **CLI** — generate deps + `lib/generated/event_sdk_setup.g.dart`

Both end with the same runtime API: `EventSdk.track(...)`.

---

## Option A — Manual (git)

### pubspec.yaml

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

Use **path** deps when developing against this monorepo locally:

```yaml
dependencies:
  event_sdk:
    path: ../flutter_blob_events/packages/event_sdk
  event_sdk_aws:
    path: ../flutter_blob_events/packages/event_sdk_aws
  event_sdk_adjust:
    path: ../flutter_blob_events/packages/event_sdk_adjust
```

### Setup file

`lib/generated/event_sdk_setup.g.dart` (or any file you prefer):

```dart
import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_aws/event_sdk_aws.dart';
import 'package:event_sdk_adjust/event_sdk_adjust.dart';

Future<void> setupEventSdk() async {
  await EventSdk.init([
    AwsPinpointAdapter(
      config: AwsPinpointConfig(amplifyConfig: amplifyconfig),
    ),
    AdjustAdapter(
      config: AdjustEventConfig(
        appToken: 'YOUR_TOKEN',
        eventTokens: {'signup': 'abc123'},
      ),
    ),
  ]);
}
```

### main.dart

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupEventSdk();
  runApp(const MyApp());
}
```

### Feature code

```dart
await EventSdk.track('signup', props: {'method': 'email'});
await EventSdk.track('purchase', exclude: [EventPlatform.adjust]);
```

---

## Option B — CLI

From your Flutter app root:

```bash
# From this monorepo while developing the CLI:
dart run event_sdk_cli init --platforms aws,adjust \
  --git-url https://github.com/PranavBlob/flutter_blob_events.git \
  --ref event_sdk
```

This will:

1. Add `event_sdk` + selected platform packages to `pubspec.yaml` (git deps)
2. Write `lib/generated/event_sdk_setup.g.dart`

Then replace the `UnimplementedError` config placeholders with real `AwsPinpointConfig` / `AdjustEventConfig` values.

### Add platforms later (same main SDK)

```bash
dart run event_sdk_cli add --platforms firebase,amplitude
```

The CLI adds both platform dependencies and regenerates the setup file. Initialize
Firebase in the host app before calling `setupEventSdk()`, then fill the generated
`AmplitudeConfig` API-key placeholder.

### Remove a platform

```bash
dart run event_sdk_cli remove --platforms adjust
```

Full CLI reference: [cli.md](cli.md).

---

## Adding a platform later (manual)

1. Add the new package git/path dependency  
2. Construct its adapter in `EventSdk.init([...])`  
3. Keep all existing `EventSdk.track` calls unchanged  

Example:

```dart
await EventSdk.init([
  AwsPinpointAdapter(config: ...),
  AdjustAdapter(config: ...),
  FirebaseAnalyticsAdapter(),
  AmplitudeAdapter(config: AmplitudeConfig(apiKey: 'YOUR_API_KEY')),
]);
```

---

## Checklist

- [ ] Only needed platform packages in `pubspec.yaml`
- [ ] `setupEventSdk()` / `EventSdk.init` called before `runApp`
- [ ] Amplify config string set for Pinpoint
- [ ] Adjust `appToken` + `eventTokens` map filled
- [ ] Feature modules import only `event_sdk`
- [ ] Optional: `onAdapterError` hooked to your logger
