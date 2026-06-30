import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/emi_calculator/presentation/screens/emi_calculator_screen.dart';
import 'package:recurring/features/no_cost_emi/presentation/screens/no_cost_emi_screen.dart';

void main() {
  testWidgets('EMI calculator shows the monthly EMI for ₹1L @ 12% / 12m',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const EmiCalculatorScreen()),
    );
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '100000'); // amount
    await tester.enterText(fields.at(1), '12'); // rate
    await tester.enterText(fields.at(2), '12'); // tenure
    await tester.pump();

    expect(find.text('₹8,885'), findsOneWidget);
  });

  testWidgets('No-Cost EMI analyzer exposes the true cost', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const NoCostEmiScreen()),
    );
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '10000'); // price
    await tester.enterText(fields.at(1), '36'); // bank rate
    await tester.enterText(fields.at(2), '9'); // tenure
    await tester.enterText(fields.at(3), '800'); // fee
    await tester.pump();

    expect(find.text('NOT ACTUALLY FREE'), findsOneWidget);
    expect(find.text('₹11,225'), findsOneWidget); // true cost
  });
}
