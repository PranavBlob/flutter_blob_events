# Firebase Analytics (`event_sdk_firebase`)

Routes `EventSdk.track` calls to Firebase Analytics.

## Add the package

```yaml
dependencies:
  event_sdk_firebase:
    git:
      url: https://github.com/PranavBlob/flutter_blob_events.git
      path: packages/event_sdk_firebase
      ref: event_sdk
```

Also depend on `event_sdk` and add a `dependency_overrides` entry for it using
the same git url/path/ref. See [Getting started](../getting_started.md).

## Initialize Firebase first

Event SDK does not own Firebase project configuration. Configure Firebase in the
host app with FlutterFire. Add Firebase Core to the host app:

```bash
flutter pub add firebase_core
dart run flutterfire_cli:flutterfire configure
```

Then initialize it before Event SDK:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupEventSdk();
  runApp(const MyApp());
}
```

Add the adapter to setup:

```dart
await EventSdk.init([
  FirebaseAnalyticsAdapter(),
]);
```

## Mapping

| Event SDK | Firebase Analytics |
|---|---|
| Event name | `FirebaseAnalytics.logEvent(name: ...)` |
| `String`, `num` properties | Sent directly |
| `bool` properties | Converted to `1` / `0` |
| Other non-null properties | Converted to strings |
| `identify(userId, traits)` | `setUserId` + `setUserProperty` |
| `flush()` | No-op; Firebase has no public manual flush API |

Firebase Analytics imposes its own event-name and parameter constraints. Use
Firebase-friendly lowercase snake_case names, such as `signup_completed`.
