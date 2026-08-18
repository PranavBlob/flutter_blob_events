# Changelog

## 0.1.0

First release of Event SDK (git distribution, `publish_to: none`).

- Core `EventSdk` API: `init`, `track`, `identify`, `flush`, enable/disable
- Shared `EventSdkConfig.defaultParams` merged into every `track`
- Platforms: AWS Pinpoint, AWS HTTP endpoint, Adjust, Firebase, Amplitude
- CLI: `init` / `add` / `remove` / `list` / `doctor`
- Example app with logging clients (no vendor credentials required)
