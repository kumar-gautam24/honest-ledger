import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/core/utils/date_x.dart';
import 'package:recurring/features/home/presentation/screens/month_plan_screen.dart';
import 'package:recurring/features/money_leak/presentation/controllers/money_leak_providers.dart';
import 'package:recurring/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  testWidgets('month statement, dues and freed-money callout render',
      (tester) async {
    final monthStart = DateTime.now().monthStart;
    // 3-month ₹3,000 EMI started last month: #1 due on the 1st of this month,
    // already paid; #3 clears within the timeline horizon → freed callout.
    final emi = emiSummary(
      startDate: monthStart.addMonths(-1),
      principal: 3000,
      months: 3,
      paidInstallments: 1,
    );
    // Flexible loan: ₹5,000 planned this month, nothing paid yet.
    final loan = loanSummary(startDate: monthStart, minPayment: 5000);
    // Monthly sub already advanced to next month ⇒ inferred paid this month.
    final sub = recurringItem(nextDueDate: monthStart.addMonths(1));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          borrowingSummariesProvider
              .overrideWith((ref) => Stream.value([emi, loan])),
          recurringItemsProvider.overrideWith((ref) => Stream.value([sub])),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const MonthPlanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Statement header: due = 1,000 (EMI #1) + 5,000 (loan plan) + 499 (sub).
    expect(find.text('DUE THIS MONTH'), findsOneWidget);
    expect(find.textContaining('6,499'), findsOneWidget);
    expect(find.text('Paid so far'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);

    // Paid rows (EMI installment + inferred sub) carry the check icon.
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));

    // The loan row is undated and shows its kind label.
    expect(find.text('LOAN'), findsOneWidget);

    // Timeline with the EMI's end called out (scroll it into view — the
    // ListView builds lazily).
    await tester.scrollUntilVisible(
      find.textContaining('Phone EMI ends'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('NEXT 12 MONTHS'), findsOneWidget);
    expect(find.textContaining('Phone EMI ends'), findsOneWidget);
  });
}
