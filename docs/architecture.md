# Architecture (Approach B)

## Goal

One product API for apps, with **selective platform packages** so unused vendor SDKs are not pulled into the binary. CLI can add platforms later without changing feature call sites.

```text
Feature code
    │
    ▼
EventSdk.track / identify / flush     ← packages/event_sdk
    │
    ▼
Router (enabled − exclude | only)
    │
    ├── event_sdk_aws          (Pinpoint)
    ├── aws_endpoint_sdk       (HTTP events API)
    ├── event_sdk_adjust       (Adjust)
    ├── event_sdk_firebase     (Firebase Analytics)
    └── event_sdk_amplitude    (Amplitude)
```

## Why not one fat package?

A single package that depends on AWS + Adjust + Firebase + Amplitude forces every app to ship all native SDKs. Approach B keeps:

- **Compile-time selection** — only listed packages in `pubspec.yaml`
- **Runtime selection** — register adapters in `init`; `enable` / `disable`
- **Per-event selection** — `exclude` / `only`

## Monorepo layout

```text
flutter_blob_events/
├── packages/
│   ├── event_sdk/           # pure Dart core
│   ├── event_sdk_aws/       # Flutter + Amplify Pinpoint
│   ├── aws_endpoint_sdk/    # Flutter + HTTP MobileTrackingEvent
│   ├── event_sdk_adjust/    # Flutter + Adjust
│   ├── event_sdk_firebase/  # Flutter + Firebase Analytics
│   ├── event_sdk_amplitude/ # Flutter + Amplitude
│   └── event_sdk_cli/       # init/add/remove tooling
├── examples/
│   └── event_sdk_example/
├── docs/
├── melos.yaml
└── pubspec.yaml             # Dart workspace root
```

## Core types

| Type | Role |
|---|---|
| `Event` | Normalized name + props + timestamp |
| `EventAdapter` | Platform contract (`init` / `track` / …) |
| `EventPlatform` | Enum id for routing |
| `EventSdk` | Static facade + registry + router |
| `EventSdkConfig` | failSoft + error hook + defaultParams |

## Adapter contract

Each platform package implements `EventAdapter` and exports a Dart config class (`AwsPinpointConfig`, `AwsEndpointConfig`, `AdjustEventConfig`, …).

Optional client seams (`PinpointAnalyticsClient`, `AwsEndpointClient`, `AdjustClient`) allow logging/fakes in tests and the example app.

Default params live in the host app’s `lib/event_sdk_config.dart` (`eventSdkDefaultParams`) and are merged into every `track` for all enabled platforms.

## Distribution

- **Git** deps with `path:` inside the monorepo (`ref: event_sdk` branch by default)
- Consuming apps must `dependency_overrides` `event_sdk` to the same git source (CLI writes this) because pub rewrites adapter `path:` deps to a commit SHA
- Local contributors use Melos / Dart workspace `path` resolution
- Not published to pub.dev (`publish_to: none`)

## Extending with a new platform

1. Add `packages/event_sdk_<name>/` implementing `EventAdapter`
2. Register id in CLI `catalog.dart`
3. Document under `docs/platforms/`
4. Apps run `event_sdk_cli add --platforms <name>` (or manual pubspec + init)

No changes required in feature `track` call sites.
