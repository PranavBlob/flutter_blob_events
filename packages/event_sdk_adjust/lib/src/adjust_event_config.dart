/// Dart config for the Adjust adapter.
class AdjustEventConfig {
  const AdjustEventConfig({
    required this.appToken,
    this.isProduction = false,
    this.eventTokens = const {},
    this.initSdk = true,
  });

  /// Adjust app token from the Adjust dashboard.
  final String appToken;

  /// When true, uses Adjust production environment; otherwise sandbox.
  final bool isProduction;

  /// Maps logical event names used in [EventSdk.track] to Adjust event tokens.
  ///
  /// Example: `{'signup': 'abc123', 'purchase': 'def456'}`.
  final Map<String, String> eventTokens;

  /// When false, assumes the host app already called `Adjust.initSdk`.
  final bool initSdk;
}
