// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:heightmaxx/main.dart';

void main() {
  testWidgets('Welcome screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the welcome screen displays the main elements.
    expect(find.text('HeightMaxx'), findsOneWidget);
    expect(
      find.text('Unlock your vertical potential.\nBuild the habit of perfect posture.'),
      findsOneWidget,
    );
    expect(find.text('Start Growing'), findsOneWidget);
  });
}
