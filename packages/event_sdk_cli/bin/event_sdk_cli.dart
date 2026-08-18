import 'dart:io';

import 'package:args/args.dart';
import 'package:event_sdk_cli/src/commands.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand('init')
    ..addCommand('add')
    ..addCommand('remove')
    ..addCommand('list')
    ..addCommand('doctor');

  parser.commands['init']!
    ..addMultiOption(
      'platforms',
      abbr: 'p',
      splitCommas: true,
      help: 'Platforms to enable (aws,adjust,firebase,amplitude).',
    )
    ..addOption(
      'git-url',
      defaultsTo: 'https://github.com/PranavBlob/flutter_blob_events.git',
      help: 'Git URL of the event_sdk monorepo.',
    )
    ..addOption(
      'ref',
      defaultsTo: 'event_sdk',
      help: 'Git ref (branch/tag/commit).',
    );

  parser.commands['add']!
    ..addMultiOption(
      'platforms',
      abbr: 'p',
      splitCommas: true,
      help: 'Platforms to add.',
    )
    ..addOption(
      'git-url',
      defaultsTo: 'https://github.com/PranavBlob/flutter_blob_events.git',
    )
    ..addOption('ref', defaultsTo: 'event_sdk');

  parser.commands['remove']!.addMultiOption(
    'platforms',
    abbr: 'p',
    splitCommas: true,
    help: 'Platforms to remove.',
  );

  late ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exitCode = 64;
    return;
  }

  final command = results.command;
  if (command == null) {
    stdout.writeln('''
Event SDK CLI

Usage:
  dart run event_sdk_cli init --platforms aws,adjust
  dart run event_sdk_cli add --platforms firebase,amplitude
  dart run event_sdk_cli remove --platforms adjust
  dart run event_sdk_cli list
  dart run event_sdk_cli doctor
''');
    return;
  }

  final appRoot = Directory.current.path;
  switch (command.name) {
    case 'init':
      await runInit(
        appRoot: appRoot,
        platforms: command['platforms'] as List<String>,
        gitUrl: command['git-url'] as String,
        ref: command['ref'] as String,
      );
    case 'add':
      await runAdd(
        appRoot: appRoot,
        platforms: command['platforms'] as List<String>,
        gitUrl: command['git-url'] as String,
        ref: command['ref'] as String,
      );
    case 'remove':
      await runRemove(
        appRoot: appRoot,
        platforms: command['platforms'] as List<String>,
      );
    case 'list':
      await runList(appRoot: appRoot);
    case 'doctor':
      await runDoctor(appRoot: appRoot);
    default:
      stderr.writeln('Unknown command: ${command.name}');
      exitCode = 64;
  }
}
