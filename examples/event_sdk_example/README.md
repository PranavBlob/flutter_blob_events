# Event SDK example app

Demo Flutter app that uses **AWS Pinpoint, Adjust, Firebase, and Amplitude**
adapters through the shared `EventSdk` API.

It uses **logging clients** by default, so events print to the console — no real AWS/Adjust credentials required.

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
| Track (all enabled) | `button_tap` → all four adapters (logged) |
| Track purchase (exclude Adjust) | `purchase` → AWS, Firebase, and Amplitude |
| Track (only AWS) | `button_tap` → AWS only |

Watch the debug console for `[pinpoint]` / `[adjust]` lines.

## Project wiring

- Setup: `lib/generated/event_sdk_setup.g.dart`
- UI: `lib/main.dart`
- Depends on workspace packages: `event_sdk`, `event_sdk_aws`, `event_sdk_adjust`

## Switch to real backends

Edit `lib/generated/event_sdk_setup.g.dart`:

1. Remove `LoggingPinpointClient` / `LoggingAdjustClient`
2. Set a real `AwsPinpointConfig.amplifyConfig` and `configureAmplify: true`
3. Set a real `AdjustEventConfig.appToken`, `eventTokens`, and `initSdk: true`
4. Initialize Firebase in `main()` before `setupEventSdk()`
5. Remove the custom Amplitude client and set a real `AmplitudeConfig.apiKey`

See:

- [Getting started](../../docs/getting_started.md)
- [AWS Pinpoint](../../docs/platforms/aws_pinpoint.md)
- [Adjust](../../docs/platforms/adjust.md)
- [Firebase](../../docs/platforms/firebase.md)
- [Amplitude](../../docs/platforms/amplitude.md)
