// test/bubble_tap_effect_test.dart
//
// Widget tests for the BubbleTapEffect component.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heightmaxx/widgets/bubble_tap_effect.dart';
import 'package:heightmaxx/theme/app_colors.dart';
import 'package:heightmaxx/theme/app_theme.dart';

void main() {
  testWidgets('BubbleTapEffect renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BubbleTapEffect(
            child: Text('tap me'),
          ),
        ),
      ),
    );

    expect(find.text('tap me'), findsOneWidget);
  });

  testWidgets('BubbleTapEffect fires onTap callback', (WidgetTester tester) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BubbleTapEffect(
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BubbleTapEffect));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('BubbleTapEffect does not fire onTap when null', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BubbleTapEffect(
            onTap: null,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );

    // Should not throw.
    await tester.tap(find.byType(BubbleTapEffect));
    await tester.pump();
  });

  testWidgets('BubbleTapEffect accepts custom color, radius, and duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BubbleTapEffect(
            onTap: () {},
            color: AppColors.accentSecondary,
            maxRadius: 80,
            duration: const Duration(milliseconds: 200),
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );

    // Verify the widget builds without error.
    expect(find.byType(BubbleTapEffect), findsOneWidget);
  });

  test('BubblePainter shouldRepaint returns true on progress change', () {
    const painter1 = BubblePainter(
      progress: 0.0,
      tapPosition: Offset(50, 50),
      maxRadius: 100,
      color: AppColors.accentPrimary,
    );
    const painter2 = BubblePainter(
      progress: 0.5,
      tapPosition: Offset(50, 50),
      maxRadius: 100,
      color: AppColors.accentPrimary,
    );

    expect(painter1.shouldRepaint(painter2), isTrue);
  });

  test('BubblePainter shouldRepaint returns false when unchanged', () {
    const painter1 = BubblePainter(
      progress: 0.5,
      tapPosition: Offset(50, 50),
      maxRadius: 100,
      color: AppColors.accentPrimary,
    );
    const painter2 = BubblePainter(
      progress: 0.5,
      tapPosition: Offset(50, 50),
      maxRadius: 100,
      color: AppColors.accentPrimary,
    );

    expect(painter1.shouldRepaint(painter2), isFalse);
  });
}
