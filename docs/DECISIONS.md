# Event SDK — locked decisions

| Topic | Choice |
|---|---|
| Architecture | Approach B — one product API, modular platform packages, Melos monorepo, CLI enablement |
| AWS | Amazon Pinpoint via `amplify_analytics_pinpoint` |
| Package name | `event_sdk` (+ `event_sdk_*` adapters) |
| Distribution | Git dependencies (path locally / git URL for apps) |
| Generated setup path | `lib/generated/event_sdk_setup.g.dart` |
| Configuration | Dart config classes (no required `.env`) |

## Integrated platforms

- `event_sdk_aws` — Pinpoint
- `event_sdk_adjust` — Adjust
- `event_sdk_firebase`
- `event_sdk_amplitude`

## Note on Pinpoint

AWS has announced end of support for Amazon Pinpoint (support ends **30 Oct 2026**). Phase 1 still targets Pinpoint as requested. Plan a follow-up adapter (e.g. Kinesis) before that date if you need long-term AWS analytics.
