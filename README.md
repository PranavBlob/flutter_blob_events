# Event SDK

One Flutter API for analytics across multiple platforms. Add only the platforms you need; enable more later without changing call sites.

```dart
await EventSdk.track('signup', props: {'method': 'email'});
```

## Docs

| Doc | What’s inside |
|---|---|
| [Demo app testing](docs/demo_app_testing.md) | Full step-by-step test with new Flutter app |
| [Getting started](docs/getting_started.md) | Install, configure AWS + Adjust, first event |
| [Usage & API](docs/usage.md) | `track` / `exclude` / `only` / `identify` / enable-disable |
| [Integration](docs/integration.md) | Manual git deps vs CLI |
| [CLI](docs/cli.md) | `init` / `add` / `remove` / `list` |
| [AWS Pinpoint](docs/platforms/aws_pinpoint.md) | Pinpoint / Amplify setup |
| [AWS HTTP endpoint](docs/platforms/aws_endpoint.md) | Custom events API (`aws_endpoint_sdk`) |
| [Adjust](docs/platforms/adjust.md) | Tokens, event map, sandbox |
| [Architecture](docs/architecture.md) | Approach B, packages, routing |
| [Decisions](docs/DECISIONS.md) | Locked product choices |
| [Example app](examples/event_sdk_example/README.md) | Run the demo locally |

## Quick start

### 1. Install with CLI (recommended)

```bash
dart pub global activate --source git \
  https://github.com/PranavBlob/flutter_blob_events.git \
  --git-path packages/event_sdk_cli \
  --git-ref event_sdk

# From your Flutter app root:
event_sdk init --platforms aws,adjust
```

The CLI adds only the selected packages and creates:

- `lib/generated/event_sdk_setup.g.dart` (generated)
- `lib/event_sdk_config.dart` (your credentials/configuration)

Fill the TODOs in `event_sdk_config.dart`, including `eventSdkDefaultParams`
(sent with every event to all platforms). Call `setupEventSdk()` in `main`,
then use `EventSdk.track(...)` anywhere. Run `event_sdk doctor` to check
missing configuration. Change defaults later with `EventSdk.setDefaultParam`.

```dart
import 'generated/event_sdk_setup.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupEventSdk();
  runApp(const MyApp());
}
```

### Manual package setup (alternative)

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

Replace the git URL/ref with your real remote when ready.

### Init manually in `main`

```dart
import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_aws/event_sdk_aws.dart';
import 'package:event_sdk_adjust/event_sdk_adjust.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EventSdk.init([
    AwsPinpointAdapter(
      config: AwsPinpointConfig(
        amplifyConfig: amplifyconfig, // from Amplify config
      ),
    ),
    AdjustAdapter(
      config: AdjustEventConfig(
        appToken: 'YOUR_ADJUST_APP_TOKEN',
        isProduction: false,
        eventTokens: {
          'signup': 'abc123',
          'purchase': 'def456',
        },
      ),
    ),
  ]);

  runApp(const MyApp());
}
```

### 3. Fire events anywhere

```dart
// All enabled platforms
await EventSdk.track('signup', props: {'method': 'email'});

// Skip Adjust for this event
await EventSdk.track(
  'debug_event',
  exclude: [EventPlatform.adjust],
);

// Only AWS Pinpoint
await EventSdk.track(
  'internal_metric',
  only: [EventPlatform.aws],
);

// Only AWS HTTP endpoint
await EventSdk.track(
  'mobile_tracking_event',
  only: [EventPlatform.awsEndpoint],
);
```

## Packages

| Package | Role | Status |
|---|---|---|
| `event_sdk` | Core API + router | Ready |
| `event_sdk_aws` | Amazon Pinpoint | Ready |
| `aws_endpoint_sdk` | AWS HTTP events endpoint | Ready |
| `event_sdk_adjust` | Adjust | Ready |
| `event_sdk_cli` | Enable platforms via CLI | Ready |
| `event_sdk_firebase` | Firebase Analytics | Ready |
| `event_sdk_amplitude` | Amplitude | Ready |

## Contributors (this monorepo)

```bash
dart pub get
dart test packages/event_sdk packages/event_sdk_cli
dart analyze packages/event_sdk packages/event_sdk_aws packages/aws_endpoint_sdk packages/event_sdk_adjust packages/event_sdk_cli
flutter test packages/event_sdk_aws packages/aws_endpoint_sdk packages/event_sdk_adjust packages/event_sdk_firebase packages/event_sdk_amplitude
cd examples/event_sdk_example && flutter run
```

## License

Private / unpublished (`publish_to: none`). See [LICENSE](LICENSE).
Distribute via git.
