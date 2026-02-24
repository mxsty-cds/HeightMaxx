import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heightmaxx/screens/homepage_screen.dart';
import 'package:heightmaxx/screens/profile_setup_screen.dart';

void main() {
  testWidgets('Complete Profile navigates to HomePageScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSetupScreen(),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Alex Carter');
    final maleChip = find.widgetWithText(ChoiceChip, 'MALE');
    await tester.ensureVisible(maleChip);
    await tester.tap(maleChip);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final moderateChip = find.widgetWithText(ChoiceChip, 'MODERATE');
    await tester.ensureVisible(moderateChip);
    await tester.tap(moderateChip);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Profile'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePageScreen), findsOneWidget);
  });
}
