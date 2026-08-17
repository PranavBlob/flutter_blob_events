/// Dart config for Amazon Pinpoint via Amplify Analytics.
class AwsPinpointConfig {
  const AwsPinpointConfig({
    required this.amplifyConfig,
    this.configureAmplify = true,
    this.addAuthPlugin = true,
  });

  /// Amplify configuration JSON (typically from `amplifyconfiguration.dart`
  /// or Amplify Gen 2 outputs serialized for the Analytics category).
  final String amplifyConfig;

  /// When true, this adapter calls `Amplify.addPlugin` / `Amplify.configure`.
  /// Set false if the host app already configured Amplify.
  final bool configureAmplify;

  /// Pinpoint analytics typically needs Cognito Identity (guest or signed-in).
  /// When [configureAmplify] is true, also registers Auth Cognito plugin.
  final bool addAuthPlugin;
}
