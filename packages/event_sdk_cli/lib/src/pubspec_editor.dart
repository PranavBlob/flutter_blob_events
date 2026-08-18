import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

import 'catalog.dart';

const _eventSdkPackageName = 'event_sdk';
const _eventSdkPackagePath = 'packages/event_sdk';

Future<void> ensureCoreAndPlatformDeps({
  required String appRoot,
  required List<PlatformSpec> platforms,
  required String gitUrl,
  required String ref,
}) async {
  final pubspecFile = File(p.join(appRoot, 'pubspec.yaml'));
  final editor = YamlEditor(await pubspecFile.readAsString());

  _ensureGitDep(
    editor,
    packageName: _eventSdkPackageName,
    packagePath: _eventSdkPackagePath,
    gitUrl: gitUrl,
    ref: ref,
  );

  for (final platform in platforms) {
    _ensureGitDep(
      editor,
      packageName: platform.packageName,
      packagePath: platform.packagePath,
      gitUrl: gitUrl,
      ref: ref,
    );
  }

  // Adapters path-depend on event_sdk. Pub rewrites those paths to a git
  // commit SHA, which does not match `ref: event_sdk` and fails version
  // solving. Force one source.
  _ensureGitDep(
    editor,
    rootKey: 'dependency_overrides',
    packageName: _eventSdkPackageName,
    packagePath: _eventSdkPackagePath,
    gitUrl: gitUrl,
    ref: ref,
  );

  await pubspecFile.writeAsString(editor.toString());
}

Future<void> removePlatformDeps({
  required String appRoot,
  required Set<String> removeIds,
}) async {
  final pubspecFile = File(p.join(appRoot, 'pubspec.yaml'));
  final editor = YamlEditor(await pubspecFile.readAsString());

  for (final id in removeIds) {
    final spec = supportedPlatforms[id];
    if (spec == null) continue;
    try {
      editor.remove(['dependencies', spec.packageName]);
    } catch (_) {
      // already absent
    }
  }

  await pubspecFile.writeAsString(editor.toString());
}

void _ensureGitDep(
  YamlEditor editor, {
  String rootKey = 'dependencies',
  required String packageName,
  required String packagePath,
  required String gitUrl,
  required String ref,
}) {
  final value = _gitSource(
    gitUrl: gitUrl,
    packagePath: packagePath,
    ref: ref,
  );

  if (_hasPath(editor, [rootKey])) {
    editor.update([rootKey, packageName], value);
    return;
  }

  editor.update([rootKey], {packageName: value});
}

Map<String, Object> _gitSource({
  required String gitUrl,
  required String packagePath,
  required String ref,
}) => {
  'git': {'url': gitUrl, 'path': packagePath, 'ref': ref},
};

bool _hasPath(YamlEditor editor, List<Object> path) {
  try {
    editor.parseAt(path);
    return true;
  } catch (_) {
    return false;
  }
}
