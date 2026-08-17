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
    'Next: fill configs in ${p.join('lib', 'generated', 'event_sdk_setup.g.dart')} '
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

Future<void> _ensureFlutterApp(String appRoot) async {
  final pubspec = File(p.join(appRoot, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    throw StateError('No pubspec.yaml in $appRoot. Run from a Flutter app.');
  }
}
