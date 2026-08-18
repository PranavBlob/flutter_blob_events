import 'dart:io';

import 'catalog.dart';

/// Adds required native entries in the host Flutter app.
///
/// This keeps `event_sdk` core vendor-agnostic and avoids shipping secrets in
/// generated code.
Future<void> ensureNativeRequirements({
  required String appRoot,
  required Iterable<PlatformSpec> platforms,
}) async {
  final platformIds = platforms.map((e) => e.id).toSet();

  // All supported analytics adapters require network access.
  if (platformIds.intersection({
    'aws',
    'adjust',
    'firebase',
    'amplitude',
  }).isNotEmpty) {
    await _ensureAndroidInternetPermission(appRoot: appRoot);
  }

  // Adjust requires ATT string on iOS (NSUserTrackingUsageDescription).
  if (platformIds.contains('adjust')) {
    await _ensureAdjustAttUsageDescription(appRoot: appRoot);
  }
}

Future<void> _ensureAndroidInternetPermission({required String appRoot}) async {
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final file = File('$appRoot/$manifestPath');
  if (!file.existsSync()) return;

  final text = await file.readAsString();
  if (text.contains('android.permission.INTERNET')) return;

  final permissionLine =
      '    <uses-permission android:name="android.permission.INTERNET" />\n';

  final applicationIndex = text.indexOf('<application');
  final updated = applicationIndex == -1
      ? (() {
          final manifestOpenPattern = RegExp(r'<manifest[^>]*>\n');
          final match = manifestOpenPattern.firstMatch(text);
          if (match == null) return text;
          final manifestOpen = match.group(0) ?? '';
          return text.replaceFirst(
            manifestOpenPattern,
            '$manifestOpen$permissionLine',
          );
        })()
      : text.substring(0, applicationIndex) +
            permissionLine +
            text.substring(applicationIndex);

  await file.writeAsString(updated);
}

Future<void> _ensureAdjustAttUsageDescription({required String appRoot}) async {
  final plistPath = 'ios/Runner/Info.plist';
  final file = File('$appRoot/$plistPath');
  if (!file.existsSync()) return;

  final text = await file.readAsString();
  if (text.contains('NSUserTrackingUsageDescription')) return;

  const usageDescription =
      'Event SDK uses analytics. Provide tracking consent to send attribution data.';

  final keyValueBlock =
      '    <key>NSUserTrackingUsageDescription</key>\n'
      '    <string>$usageDescription</string>\n';

  final dictCloseIndex = text.lastIndexOf('</dict>');
  if (dictCloseIndex == -1) return;

  final updated =
      text.substring(0, dictCloseIndex) +
      keyValueBlock +
      text.substring(dictCloseIndex);
  await file.writeAsString(updated);
}
