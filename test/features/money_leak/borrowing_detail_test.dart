import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/core/utils/money_formatter.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';
import 'package:recurring/features/money_leak/presentation/controllers/money_leak_providers.dart';
import 'package:recurring/features/money_leak/presentation/screens/borrowing_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(String id, BorrowingSummary summary) {
  return ProviderScope(
    overrides: [
      borrowingSummaryProvider(id).overrideWith((ref) => Stream.value(summary)),
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: BorrowingDetailScreen(borrowingId: id),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  testWidgets(
      'no-cost EMI shows the badge and the seller-discount-covered row',
      (tester) async {
    final startDate = DateTime(2026, 1, 1);
    final b = Borrowing(
      id: 'emi-nc',
      title: 'Phone',
      lenderName: 'Test Bank',
      principal: 12000,
      startDate: startDate,
      createdAt: startDate,
      kind: BorrowingKind.fixedEmi,
      interestRatePct: 18,
      rateType: RateType.reducing,
      tenureMonths: 6,
      gstOnInterest: true,
      isNoCostEmi: true,
      status: BorrowingStatus.active,
    );
    final summary = BorrowingSummary.from(b, const []);
    final discount = FinanceMath.noCostDiscount(
      price: b.principal,
      bankAnnualRatePct: b.interestRatePct,
      months: b.tenureMonths,
    );

    await tester.pumpWidget(_app('emi-nc', summary));
    await tester.pumpAndSettle();

    expect(find.text('NO-COST EMI'), findsOneWidget);
    expect(find.text('Seller discount covered'), findsOneWidget);
    expect(find.text(Money.format(discount)), findsOneWidget);
  });

  testWidgets(
      'a regular EMI shows neither the no-cost badge nor the discount row',
      (tester) async {
    final startDate = DateTime(2026, 1, 1);
    final b = Borrowing(
      id: 'emi-reg',
      title: 'Laptop',
      lenderName: 'Test Bank',
      principal: 12000,
      startDate: startDate,
      createdAt: startDate,
      kind: BorrowingKind.fixedEmi,
      interestRatePct: 18,
      tenureMonths: 6,
      status: BorrowingStatus.active,
    );
    final summary = BorrowingSummary.from(b, const []);

    await tester.pumpWidget(_app('emi-reg', summary));
    await tester.pumpAndSettle();

    expect(find.text('NO-COST EMI'), findsNothing);
    expect(find.text('Seller discount covered'), findsNothing);
  });

  testWidgets('a fee-financed loan shows the financed-fee interest row',
      (tester) async {
    final startDate = DateTime.now().subtract(const Duration(days: 45));
    final b = Borrowing(
      id: 'loan-ff',
      title: 'Quick advance',
      lenderName: 'Slice',
      principal: 10000,
      processingFee: 200,
      gstOnFee: 36,
      startDate: startDate,
      createdAt: startDate,
      kind: BorrowingKind.flexibleLoan,
      interestRatePct: 24,
      minPayment: 1000,
      feeFinanced: true,
      status: BorrowingStatus.active,
    );
    final repayments = [
      Repayment(
        id: 'r1',
        borrowingId: b.id,
        amount: 10500,
        date: DateTime.now(),
      ),
    ];
    final summary = BorrowingSummary.from(b, repayments);
    // Sanity: this scenario only exercises the row when something has
    // actually leaked so far.
    expect(summary.wastedSoFar, greaterThan(0));

    await tester.pumpWidget(_app('loan-ff', summary));
    await tester.pumpAndSettle();

    expect(find.text('Interest on the financed fee'), findsOneWidget);
  });
}
