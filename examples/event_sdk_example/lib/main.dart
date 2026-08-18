import 'package:event_sdk/event_sdk.dart';
import 'package:flutter/material.dart';

import 'generated/event_sdk_setup.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupEventSdk();
  runApp(const EventSdkExampleApp());
}

class EventSdkExampleApp extends StatelessWidget {
  const EventSdkExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _log = <String>[];

  Future<void> _trackAll() async {
    await EventSdk.track('button_tap', props: {'source': 'example'});
    setState(() => _log.insert(0, 'tracked button_tap → all platforms'));
  }

  Future<void> _trackExcludeAdjust() async {
    await EventSdk.track(
      'purchase',
      props: {'revenue': 9.99, 'currency': 'USD'},
      exclude: [EventPlatform.adjust],
    );
    setState(() => _log.insert(0, 'tracked purchase → exclude adjust'));
  }

  Future<void> _trackOnlyAws() async {
    await EventSdk.track('button_tap', only: [EventPlatform.aws]);
    setState(() => _log.insert(0, 'tracked button_tap → only aws'));
  }

  Future<void> _trackOnlyAwsEndpoint() async {
    await EventSdk.track(
      'button_tap',
      only: [EventPlatform.awsEndpoint],
    );
    setState(() => _log.insert(0, 'tracked button_tap → only aws_endpoint'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event SDK')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: _trackAll,
              child: const Text('Track (all enabled)'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _trackExcludeAdjust,
              child: const Text('Track purchase (exclude Adjust)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _trackOnlyAws,
              child: const Text('Track (only AWS Pinpoint)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _trackOnlyAwsEndpoint,
              child: const Text('Track (only AWS HTTP)'),
            ),
            const SizedBox(height: 24),
            Text('Log', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  title: Text(_log[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
