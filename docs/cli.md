# Event SDK CLI

Package: `packages/event_sdk_cli`  
Executable: `event_sdk_cli`

Helps apps enable platforms without hand-wiring every dependency.

## Run from this monorepo

```bash
# from flutter_blob_events/
dart run event_sdk_cli <command>
```

Or from an app that depends on the CLI package:

```bash
dart run event_sdk_cli <command>
```

Run commands from the **Flutter app root** (where `pubspec.yaml` lives).

---

## Commands

### `list`

```bash
dart run event_sdk_cli list
```

Shows supported platforms and which ones look enabled in the current app (from generated setup).

### `init`

```bash
dart run event_sdk_cli init --platforms aws,adjust \
  --git-url https://github.com/PranavBlob/flutter_blob_events.git \
  --ref event_sdk
```

| Flag | Default | Meaning |
|---|---|---|
| `--platforms` / `-p` | (required) | Comma-separated: `aws`, `adjust`, … |
| `--git-url` | `https://github.com/PranavBlob/flutter_blob_events.git` | Monorepo git URL |
| `--ref` | `event_sdk` | Branch / tag / commit |

Creates / updates:

- Git deps in `pubspec.yaml` for `event_sdk` + selected platforms
- `lib/generated/event_sdk_setup.g.dart`

### `add`

```bash
dart run event_sdk_cli add --platforms firebase,amplitude
```

Merges new platforms into existing setup.  
`firebase` and `amplitude` are available and can be added to an existing
integration. Initialize Firebase in the host app before `setupEventSdk()`, then
replace the generated Amplitude config placeholder with your API key.

### `remove`

```bash
dart run event_sdk_cli remove --platforms adjust
```

Removes platform deps and regenerates setup. Refuses to remove the last platform.

---

## Generated file

Path (standard):

```text
lib/generated/event_sdk_setup.g.dart
```

After generation, replace placeholder configs:

```dart
AwsPinpointAdapter(
  config: AwsPinpointConfig(amplifyConfig: amplifyconfig),
),
AdjustAdapter(
  config: AdjustEventConfig(
    appToken: '...',
    eventTokens: {'signup': '...'},
  ),
),
```

Then in `main.dart`:

```dart
await setupEventSdk();
```

---

## Current platform catalog

| Id | Package | Available |
|---|---|---|
| `aws` | `event_sdk_aws` | Yes |
| `adjust` | `event_sdk_adjust` | Yes |
| `firebase` | `event_sdk_firebase` | Yes |
| `amplitude` | `event_sdk_amplitude` | Yes |
