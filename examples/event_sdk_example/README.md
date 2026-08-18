# Event SDK example app

Demo Flutter app that uses **AWS Pinpoint, AWS HTTP endpoint, Adjust, Firebase,
and Amplitude** adapters through the shared `EventSdk` API.

It uses **logging clients** by default, so events print to the console — no real
vendor credentials required.

Default params (`source`, `env`) are set in `setupEventSdk()` and merged into
every track for all adapters.

## Run

From the monorepo root:

```bash
dart pub get
cd examples/event_sdk_example
flutter run
```

## What you can try

On the home screen:

| Button | Behavior |
|---|---|
| Track (all enabled) | `button_tap` → all five adapters (logged) |
| Track purchase (exclude Adjust) | `purchase` → Pinpoint, HTTP, Firebase, Amplitude |
| Track (only AWS Pinpoint) | `button_tap` → `EventPlatform.aws` only |
| Track (only AWS HTTP) | `button_tap` → `EventPlatform.awsEndpoint` only |

Watch the debug console for `[pinpoint]` / `[aws_endpoint]` / `[adjust]` lines.

## Project wiring

- Setup: `lib/generated/event_sdk_setup.g.dart`
- UI: `lib/main.dart`
- Depends on workspace packages: `event_sdk`, `event_sdk_aws`, `aws_endpoint_sdk`, `event_sdk_adjust`, `event_sdk_firebase`, `event_sdk_amplitude`

## Switch to real backends

Edit `lib/generated/event_sdk_setup.g.dart`:

1. Remove `LoggingPinpointClient` / `LoggingAwsEndpointClient` / `LoggingAdjustClient`
2. Set a real `AwsPinpointConfig.amplifyConfig` and `configureAmplify: true`
3. Set a real `AwsEndpointConfig.endpoint` and device/user default fields
4. Set a real `AdjustEventConfig.appToken`, `eventTokens`, and `initSdk: true`
5. Initialize Firebase in `main()` before `setupEventSdk()`
6. Remove the custom Amplitude client and set a real `AmplitudeConfig.apiKey`

See:

- [Getting started](../../docs/getting_started.md)
- [AWS Pinpoint](../../docs/platforms/aws_pinpoint.md)
- [AWS HTTP endpoint](../../docs/platforms/aws_endpoint.md)
- [Adjust](../../docs/platforms/adjust.md)
- [Firebase](../../docs/platforms/firebase.md)
- [Amplitude](../../docs/platforms/amplitude.md)
- [Usage (default params)](../../docs/usage.md)
