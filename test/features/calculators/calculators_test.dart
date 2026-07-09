import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/core/utils/money_formatter.dart';
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
    // True cost is now computed on the discount-exact model (interest on the
    // discounted principal, not the sticker price) — was ₹11,225 under the
    // old full-price approximation.
    expect(find.text('₹11,187'), findsOneWidget); // true cost
    // The seller's discount is surfaced as its own line above the GST row.
    expect(find.text('Seller discount covers'), findsOneWidget);
    expect(find.text('₹1,349'), findsOneWidget); // merchant discount
  });

  testWidgets(
      'No-Cost EMI analyzer verdicts when upfront costs less than the EMI',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const NoCostEmiScreen()),
    );
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '10000'); // price
    await tester.enterText(fields.at(1), '36'); // bank rate
    await tester.enterText(fields.at(2), '9'); // tenure
    await tester.enterText(fields.at(3), '800'); // fee
    await tester.enterText(fields.at(4), '300'); // forfeited discount
    await tester.pump();

    // Forfeiting a real cash discount to take the EMI is never cheaper once
    // the bank's hidden interest/GST is added on top, so this direction is
    // the one an ordinary checkout actually produces.
    //
    // The gap is exactly totalExtra: EMI cash outlay (price + ≈₹243 GST on
    // the bank's interest + ₹800 fee + ₹144 GST on the fee) minus the upfront
    // outlay (price − ₹300) = 243 + 800 + 144 + 300 ≈ ₹1,487. Comparing
    // trueCost against the upfront outlay instead double-counts the forfeited
    // ₹300 (trueCost already carries it as a cost line) and wrongly showed
    // ₹1,787 here.
    expect(find.text('Paying upfront is cheaper by ₹1,487.'), findsOneWidget);
  });

  testWidgets('No-Cost EMI analyzer hides the verdict without a discount',
      (tester) async {
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

    expect(find.textContaining('cheaper by'), findsNothing);
    expect(find.textContaining('wins by'), findsNothing);
    expect(find.textContaining('costs about the same'), findsNothing);
  });

  group('noCostVerdict', () {
    // The verdict amount is totalExtra itself — the exact difference between
    // the EMI cash outlay and the upfront outlay (see noCostVerdict docs).
    test('upfront cheaper', () {
      expect(
        noCostVerdict(totalExtra: 2000, forfeitedDiscount: 500),
        'Paying upfront is cheaper by ${Money.format(2000)}.',
      );
    });

    test('no-cost EMI wins (guarded branch, unreachable via real inputs)', () {
      expect(
        noCostVerdict(totalExtra: -500, forfeitedDiscount: 500),
        'No-cost EMI wins by ${Money.format(500)}.',
      );
    });

    test('a wash within a rupee', () {
      expect(
        noCostVerdict(totalExtra: 0.5, forfeitedDiscount: 500),
        'Either way costs about the same.',
      );
      expect(
        noCostVerdict(totalExtra: -0.5, forfeitedDiscount: 500),
        'Either way costs about the same.',
      );
    });

    test('no discount entered means no verdict', () {
      expect(
        noCostVerdict(totalExtra: 2000, forfeitedDiscount: 0),
        isNull,
      );
    });
  });
}
