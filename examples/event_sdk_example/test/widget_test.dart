import 'package:flutter_test/flutter_test.dart';

import 'package:event_sdk_example/main.dart';

void main() {
  testWidgets('renders Event SDK home', (tester) async {
    await tester.pumpWidget(const EventSdkExampleApp());
    expect(find.text('Event SDK'), findsOneWidget);
    expect(find.text('Track (all enabled)'), findsOneWidget);
  });
}
