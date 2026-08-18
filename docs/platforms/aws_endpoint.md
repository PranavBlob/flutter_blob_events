# AWS HTTP endpoint platform (`aws_endpoint_sdk`)

Sends events to a **custom HTTP analytics endpoint** using the
**MobileTrackingEvent** JSON format (aligned with iOS `AWSAnalyticsDispatcher`).

Use this when your backend is a REST URL such as:

```text
https://dev-events.atomapplications.com/api/dev/v1
```

This is **not** Amplify/Pinpoint. For Pinpoint, use [`event_sdk_aws`](aws_pinpoint.md).

## Dependency

```yaml
aws_endpoint_sdk:
  git:
    url: https://github.com/PranavBlob/flutter_blob_events.git
    path: packages/aws_endpoint_sdk
    ref: event_sdk
```

## CLI

```bash
event_sdk init --platforms aws_endpoint,adjust
# or add later:
event_sdk add --platforms aws_endpoint
```

Fill placeholders in `lib/event_sdk_config.dart`, including the endpoint URL and
device/user default fields.

---

## Config — `AwsEndpointConfig`

```dart
AwsEndpointConfig({
  required String endpoint,
  AwsEndpointDefaultFields defaultFields = const AwsEndpointDefaultFields(),
  String stream = 'mobile-tracking-event',
  Map<String, String> adjustAttribution = const {},
})
```

### Example

```dart
import 'package:aws_endpoint_sdk/aws_endpoint_sdk.dart';

AwsEndpointAdapter(
  config: AwsEndpointConfig(
    endpoint: 'https://dev-events.atomapplications.com/api/dev/v1',
    defaultFields: AwsEndpointDefaultFields(
      appName: 'MyApp',
      platform: 'Android',
      appId: 'com.example.app',
      deviceId: deviceId,
      installId: installId,
      userId: userId,
      appVersion: '1.0.0',
      appEnvironment: 'dev',
      osVersion: osVersion,
      deviceModel: deviceModel,
      languageCode: 'en',
      userType: 'guest',
      gaid: gaid,
    ),
  ),
)
```

Update metadata at runtime:

```dart
final adapter = createAwsEndpointAdapter() as AwsEndpointAdapter;
adapter.updateDefaultFields(
  AwsEndpointDefaultFields(deviceId: newDeviceId, userId: newUserId),
);
adapter.setAdjustAttribution({'network': 'Meta', 'campaign': 'spring'});
```

---

## Event mapping

Each `EventSdk.track(...)` becomes an HTTP `POST` with JSON body:

| Field | Source |
|---|---|
| `ename` | Event name |
| `app`, `os`, `appId`, `deviceId`, … | `AwsEndpointDefaultFields` |
| Adjust attribution keys | `adjustAttribution` / `setAdjustAttribution` |
| `stream` | `AwsEndpointConfig.stream` (default `mobile-tracking-event`) |
| `parameters` | Event props (includes [default params](../usage.md#default-params)) |

Example body:

```json
{
  "ename": "signup",
  "app": "MyApp",
  "os": "Android",
  "appId": "com.example.app",
  "deviceId": "abc",
  "userId": "user_1",
  "stream": "mobile-tracking-event",
  "parameters": {
    "source": "mobile_app",
    "method": "email"
  }
}
```

`parameters` values are stringified. Null props are omitted.

---

## Default params (core SDK — all platforms)

Edit `eventSdkDefaultParams` in `lib/event_sdk_config.dart`. Those keys are
merged into **every** event for **all** platforms, not only this HTTP adapter.

On this adapter they appear under `parameters`.

```dart
EventSdk.setDefaultParam('userType', 'premium');
await EventSdk.track('signup', props: {'method': 'email'});
// parameters => source/env from config + userType + method
```

---

## `identify`

Updates `userId` in the top-level payload. Optional `traits` are merged into
`defaultFields.extra` as string values.

---

## Local demo without network

```dart
AwsEndpointAdapter(
  config: const AwsEndpointConfig(
    endpoint: 'https://dev-events.example.com/api/dev/v1',
  ),
  client: LoggingAwsEndpointClient(),
)
```

---

## Pinpoint vs HTTP endpoint

| | `event_sdk_aws` (Pinpoint) | `aws_endpoint_sdk` |
|---|---|---|
| Transport | Amplify SDK | HTTP POST |
| Config | Amplify JSON | Endpoint URL + default fields |
| Backend | AWS Pinpoint | Your events API |

Both register as different platforms: `EventPlatform.aws` vs `EventPlatform.awsEndpoint`.

```dart
await EventSdk.track('signup', only: [EventPlatform.awsEndpoint]);
```
