import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml_edit/yaml_edit.dart';

import 'catalog.dart';

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
    packageName: 'event_sdk',
    packagePath: 'packages/event_sdk',
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
  required String packageName,
  required String packagePath,
  required String gitUrl,
  required String ref,
}) {
  editor.update(
    ['dependencies', packageName],
    {
      'git': {'url': gitUrl, 'path': packagePath, 'ref': ref},
    },
  );
}
