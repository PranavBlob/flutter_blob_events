import 'dart:io';

import 'package:path/path.dart' as p;

import 'catalog.dart';
import 'generator.dart';
import 'pubspec_editor.dart';

Future<void> runInit({
  required String appRoot,
  required List<String> platforms,
  required String gitUrl,
  required String ref,
}) async {
  final specs = resolvePlatforms(platforms);
  await _ensureFlutterApp(appRoot);
  await ensureCoreAndPlatformDeps(
    appRoot: appRoot,
    platforms: specs,
    gitUrl: gitUrl,
    ref: ref,
  );
  await writeSetupFile(appRoot: appRoot, platforms: specs);
  stdout.writeln(
    'Initialized Event SDK with: ${specs.map((s) => s.id).join(', ')}',
  );
  stdout.writeln(
    'Next: fill credentials in ${p.join('lib', 'event_sdk_config.dart')} '
    'and call setupEventSdk() from main().',
  );
}

Future<void> runAdd({
  required String appRoot,
  required List<String> platforms,
  required String gitUrl,
  required String ref,
}) async {
  final specs = resolvePlatforms(platforms);
  await _ensureFlutterApp(appRoot);
  final existing = await readEnabledPlatforms(appRoot);
  final mergedIds = {...existing, ...specs.map((s) => s.id)}.toList()..sort();
  final merged = resolvePlatforms(mergedIds);
  await ensureCoreAndPlatformDeps(
    appRoot: appRoot,
    platforms: merged,
    gitUrl: gitUrl,
    ref: ref,
  );
  await writeSetupFile(appRoot: appRoot, platforms: merged);
  stdout.writeln('Enabled platforms: ${merged.map((s) => s.id).join(', ')}');
}

Future<void> runRemove({
  required String appRoot,
  required List<String> platforms,
}) async {
  final toRemove = platforms.map((e) => e.trim().toLowerCase()).toSet();
  final existing = await readEnabledPlatforms(appRoot);
  final remainingIds = existing.where((id) => !toRemove.contains(id)).toList();
  if (remainingIds.isEmpty) {
    stderr.writeln('Refusing to remove all platforms. Use at least one.');
    exitCode = 1;
    return;
  }
  final remaining = resolvePlatforms(remainingIds);
  await removePlatformDeps(appRoot: appRoot, removeIds: toRemove);
  await removePlatformFromConfig(appRoot: appRoot, platformIds: toRemove);
  await writeSetupFile(appRoot: appRoot, platforms: remaining);
  stdout.writeln(
    'Remaining platforms: ${remaining.map((s) => s.id).join(', ')}',
  );
}

Future<void> runList({required String appRoot}) async {
  stdout.writeln('Supported platforms:');
  for (final spec in supportedPlatforms.values) {
    final status = spec.available ? 'available' : 'planned';
    stdout.writeln('  - ${spec.id} ($status)');
  }
  final enabled = await readEnabledPlatforms(appRoot);
  stdout.writeln(
    enabled.isEmpty
        ? 'Enabled in this app: (none)'
        : 'Enabled in this app: ${enabled.join(', ')}',
  );
}

Future<void> runDoctor({required String appRoot}) async {
  final pubspec = File(p.join(appRoot, 'pubspec.yaml'));
  final setup = File(p.join(appRoot, setupRelativePath));
  final config = File(p.join(appRoot, configRelativePath));
  final issues = <String>[];

  if (!pubspec.existsSync()) {
    issues.add(
      'No pubspec.yaml found. Run this command from a Flutter app root.',
    );
  }
  if (!setup.existsSync()) {
    issues.add('Missing $setupRelativePath. Run `event_sdk_cli init` first.');
  }
  if (!config.existsSync()) {
    issues.add('Missing $configRelativePath. Run `event_sdk_cli init` first.');
  } else {
    final configText = await config.readAsString();
    if (configText.contains('REPLACE_WITH_')) {
      issues.add('Replace credential placeholders in $configRelativePath.');
    }
    if (configText.contains('createFirebaseAdapter')) {
      issues.add(
        'Firebase selected: initialize Firebase before setupEventSdk() in main().',
      );
    }
  }

  if (issues.isEmpty) {
    stdout.writeln('Event SDK doctor: configuration files look ready.');
    return;
  }

  stdout.writeln('Event SDK doctor found ${issues.length} item(s):');
  for (final issue in issues) {
    stdout.writeln('  - $issue');
  }
  exitCode = 1;
}

Future<void> _ensureFlutterApp(String appRoot) async {
  final pubspec = File(p.join(appRoot, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    throw StateError('No pubspec.yaml in $appRoot. Run from a Flutter app.');
  }
}
