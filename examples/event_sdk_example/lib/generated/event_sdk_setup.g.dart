import 'package:event_sdk/event_sdk.dart';
import 'package:event_sdk_adjust/event_sdk_adjust.dart';
import 'package:event_sdk_amplitude/event_sdk_amplitude.dart';
import 'package:event_sdk_aws/event_sdk_aws.dart';
import 'package:event_sdk_firebase/event_sdk_firebase.dart';

/// Demo setup — uses logging clients so the example runs without real credentials.
///
/// For production, remove the custom clients and set:
/// - [AwsPinpointConfig.amplifyConfig] + configureAmplify: true
/// - [AdjustEventConfig.initSdk]: true with a real app token / event token map
/// - Firebase initialization in the host app before [setupEventSdk]
/// - [AmplitudeConfig.apiKey]
Future<void> setupEventSdk() async {
  await EventSdk.init(
    [
      AwsPinpointAdapter(
        config: const AwsPinpointConfig(
          amplifyConfig: '{}',
          configureAmplify: false,
        ),
        client: LoggingPinpointClient(),
      ),
      AdjustAdapter(
        config: const AdjustEventConfig(
          appToken: 'DEMO_TOKEN',
          initSdk: false,
          eventTokens: {
            'button_tap': 'demo_event_token',
            'purchase': 'demo_purchase_token',
          },
        ),
        client: LoggingAdjustClient(),
      ),
      FirebaseAnalyticsAdapter(client: _LoggingFirebaseClient()),
      AmplitudeAdapter(
        config: const AmplitudeConfig(apiKey: 'DEMO_API_KEY'),
        client: _LoggingAmplitudeClient(),
      ),
    ],
    config: EventSdkConfig(
      defaultParams: {
        'source': 'event_sdk_example',
        'env': 'demo',
      },
      onAdapterError: (error, stack) {
        // ignore: avoid_print
        print('EventSdk adapter error: $error');
      },
    ),
  );
}

class _LoggingFirebaseClient implements FirebaseAnalyticsClient {
  @override
  Future<void> setUserId(String userId) async {
    // ignore: avoid_print
    print('[firebase] identify $userId');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    // ignore: avoid_print
    print('[firebase] user property $name=$value');
  }

  @override
  Future<void> track(String name, Map<String, Object> parameters) async {
    // ignore: avoid_print
    print('[firebase] $name $parameters');
  }
}

class _LoggingAmplitudeClient implements AmplitudeAnalyticsClient {
  @override
  Future<void> flush() async {
    // ignore: avoid_print
    print('[amplitude] flush');
  }

  @override
  Future<void> identify(String userId, {Map<String, Object?>? traits}) async {
    // ignore: avoid_print
    print('[amplitude] identify $userId $traits');
  }

  @override
  Future<void> init(AmplitudeConfig config) async {
    // ignore: avoid_print
    print('[amplitude] initialized');
  }

  @override
  Future<void> track(Event event) async {
    // ignore: avoid_print
    print('[amplitude] ${event.name} ${event.props}');
  }
}
