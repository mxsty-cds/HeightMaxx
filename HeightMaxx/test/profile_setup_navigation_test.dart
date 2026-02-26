import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heightmaxx/screens/homepage_screen.dart';
import 'package:heightmaxx/screens/profile_setup_screen.dart';

void main() {
  testWidgets('Complete Profile navigates to HomePageScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileSetupScreen()));

    await tester.enterText(find.byType(TextField).first, 'Alex Carter');
    final maleOption = find.text('Male');
    await tester.ensureVisible(maleOption);
    await tester.tap(maleOption);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final moderateOption = find.text('Moderate');
    await tester.ensureVisible(moderateOption);
    await tester.tap(moderateOption);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Profile'));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(HomePageScreen), findsOneWidget);
  });

  testWidgets('Feet height is converted to cm in created profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileSetupScreen()));

    await tester.enterText(find.byType(TextField).first, 'Alex Carter');
    final maleOption = find.text('Male');
    await tester.ensureVisible(maleOption);
    await tester.tap(maleOption);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final moderateOption = find.text('Moderate');
    await tester.ensureVisible(moderateOption);
    await tester.tap(moderateOption);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Profile'));
    await tester.pump(const Duration(milliseconds: 600));

    final homePage = tester.widget<HomePageScreen>(find.byType(HomePageScreen));
    expect(homePage.user, isNotNull);
    expect(homePage.user!.heightCm, 175.3);
  });
}
