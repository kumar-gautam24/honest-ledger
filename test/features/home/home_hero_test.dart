import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/core/utils/date_x.dart';
import 'package:recurring/features/cards/presentation/controllers/card_providers.dart';
import 'package:recurring/features/home/presentation/screens/home_screen.dart';
import 'package:recurring/features/money_leak/presentation/controllers/money_leak_providers.dart';
import 'package:recurring/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:recurring/features/settings/presentation/controllers/income_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

class _FixedIncome extends IncomeController {
  _FixedIncome(this.value);
  final double? value;
  @override
  double? build() => value;
}

Widget _app({double? income}) {
  final monthStart = DateTime.now().monthStart;
  // Loan with a ₹5,000 plan, nothing paid → remaining 5,000 this month.
  final loan = loanSummary(startDate: monthStart, minPayment: 5000);
  return ProviderScope(
    overrides: [
      borrowingSummariesProvider.overrideWith((ref) => Stream.value([loan])),
      recurringItemsProvider.overrideWith((ref) => Stream.value(const [])),
      cardsProvider.overrideWith((ref) => Stream.value(const [])),
      allCardStatementsProvider.overrideWith((ref) => Stream.value(const [])),
      incomeControllerProvider.overrideWith(() => _FixedIncome(income)),
    ],
    child: MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  testWidgets('hero leads with remaining this month, wasted is secondary',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('REMAINING THIS MONTH'), findsOneWidget);
    expect(find.textContaining('5,000'), findsWidgets);
    expect(find.textContaining('due '), findsOneWidget);
    expect(find.text('LIFETIME WASTED'), findsOneWidget);
    // Income unset → no left-after line.
    expect(find.textContaining('left after obligations'), findsNothing);
  });

  testWidgets('income set shows the left-after-obligations line',
      (tester) async {
    await tester.pumpWidget(_app(income: 85000));
    await tester.pumpAndSettle();

    // 85,000 − 5,000 due = 80,000 left.
    expect(find.textContaining('80,000 left after obligations'), findsOneWidget);
  });

  testWidgets('no arrears → no catch-up card', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('WHILE YOU WERE AWAY'), findsNothing);
  });

  testWidgets('arrears show the catch-up card and open the sheet',
      (tester) async {
    // EMI started 3 months before this month with nothing paid → at least two
    // pre-month installments are in arrears regardless of today's date.
    final monthStart = DateTime.now().monthStart;
    final late = emiSummary(startDate: monthStart.addMonths(-3));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          borrowingSummariesProvider
              .overrideWith((ref) => Stream.value([late])),
          recurringItemsProvider.overrideWith((ref) => Stream.value(const [])),
          cardsProvider.overrideWith((ref) => Stream.value(const [])),
          allCardStatementsProvider
              .overrideWith((ref) => Stream.value(const [])),
          incomeControllerProvider.overrideWith(() => _FixedIncome(null)),
        ],
        child: MaterialApp(theme: AppTheme.dark(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('WHILE YOU WERE AWAY'), findsOneWidget);
    expect(find.textContaining('EMI installment'), findsOneWidget);

    await tester.tap(find.text('WHILE YOU WERE AWAY'));
    await tester.pumpAndSettle();

    // Sheet: every arrear pre-checked + one mark-paid button (label carries
    // the running total).
    expect(find.textContaining('Mark paid'), findsOneWidget);
    final boxes = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(boxes.length, greaterThanOrEqualTo(2));
    expect(boxes.every((b) => b.value == true), isTrue);
  });
}
