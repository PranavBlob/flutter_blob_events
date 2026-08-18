# AWS Pinpoint platform (`event_sdk_aws`)

Sends events through **Amplify Analytics → Amazon Pinpoint**.

If your backend is a custom REST URL (for example
`https://dev-events.atomapplications.com/api/dev/v1`) instead of Pinpoint,
use [`aws_endpoint_sdk`](aws_endpoint.md). Do not put that URL in
`AwsPinpointConfig.amplifyConfig`.

## Dependency

```yaml
event_sdk_aws:
  git:
    url: https://github.com/PranavBlob/flutter_blob_events.git
    path: packages/event_sdk_aws
    ref: event_sdk
```

Pulls in (transitively): `amplify_flutter`, `amplify_analytics_pinpoint`, `amplify_auth_cognito`.

## Config — `AwsPinpointConfig`

```dart
AwsPinpointConfig({
  required String amplifyConfig, // Amplify JSON config string
  bool configureAmplify = true,  // false if app already configured Amplify
  bool addAuthPlugin = true,     // Cognito identity for analytics
})
```

### Example

```dart
import 'package:event_sdk_aws/event_sdk_aws.dart';
import 'amplifyconfiguration.dart'; // amplifyconfig string

AwsPinpointAdapter(
  config: AwsPinpointConfig(
    amplifyConfig: amplifyconfig,
    configureAmplify: true,
    addAuthPlugin: true,
  ),
)
```

If your app already calls `Amplify.configure`:

```dart
AwsPinpointAdapter(
  config: AwsPinpointConfig(
    amplifyConfig: amplifyconfig,
    configureAmplify: false,
  ),
)
```

## Event mapping

| Event SDK | Pinpoint |
|---|---|
| `name` | Analytics event name |
| `props` (`String`/`bool`/`int`/`double`) | Custom properties |
| other prop types | Converted with `toString()` |
| `identify(userId, traits)` | `Amplify.Analytics.identifyUser` |
| `flush()` | `Amplify.Analytics.flushEvents` |

```dart
await EventSdk.track(
  'signup',
  props: {
    'method': 'email',
    'is_trial': true,
    'step': 1,
  },
);
```

## Local demo without AWS

Use the logging client (as in the example app):

```dart
AwsPinpointAdapter(
  config: const AwsPinpointConfig(
    amplifyConfig: '{}',
    configureAmplify: false,
  ),
  client: LoggingPinpointClient(),
)
```

## Amplify setup notes

1. Create/configure Amplify Analytics (Pinpoint) for your app  
2. Ensure Cognito Identity allows unauthenticated and/or authenticated analytics as needed  
3. Copy the generated config into your Flutter project (`amplifyconfiguration.dart` or Gen 2 outputs)  
4. Pass that JSON string into `AwsPinpointConfig.amplifyConfig`

Official Amplify Flutter analytics docs are the source of truth for cloud setup.

## Pinpoint end of support

AWS ends support for Amazon Pinpoint on **30 Oct 2026**. This adapter targets Pinpoint as requested for Phase 1. Plan a follow-up AWS adapter (e.g. Kinesis) before that date if you need long-term AWS event ingestion.
