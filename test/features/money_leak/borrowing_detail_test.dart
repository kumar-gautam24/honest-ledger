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

  Borrowing feeFinancedLoan(DateTime startDate, {double ratePct = 24}) =>
      Borrowing(
        id: 'loan-ff',
        title: 'Quick advance',
        lenderName: 'Slice',
        principal: 10000,
        processingFee: 200,
        gstOnFee: 36,
        startDate: startDate,
        createdAt: startDate,
        kind: BorrowingKind.flexibleLoan,
        interestRatePct: ratePct,
        minPayment: 1000,
        feeFinanced: true,
        status: BorrowingStatus.active,
      );

  /// The fee's proportional share of the interest accrued on the
  /// fee-inclusive balance (₹10,236 at 24% p.a. reducing) — the same
  /// derivation the summary + detail screen use, computed independently so
  /// the row's exact rupee figure is asserted, not just its presence.
  double expectedFeeShare(Borrowing b, List<Repayment> repayments) {
    final accrued = FinanceMath.accruedInterestFlexible(
      principal: b.principal + b.processingFee + b.gstOnFee,
      annualRatePct: b.interestRatePct,
      startDate: b.startDate,
      payments: [for (final r in repayments) (r.date, r.amount)],
    );
    return FinanceMath.financedFeeInterestShare(
      principal: b.principal + b.processingFee + b.gstOnFee,
      financedAmount: b.processingFee + b.gstOnFee,
      totalInterest: accrued,
    );
  }

  testWidgets(
      'fee-financed loan: row shows the fee share of accrued interest, '
      'not a share of repaid-beyond-principal', (tester) async {
    final b =
        feeFinancedLoan(DateTime.now().subtract(const Duration(days: 45)));
    final repayments = [
      Repayment(
        id: 'r1',
        borrowingId: b.id,
        amount: 10500,
        date: DateTime.now(),
      ),
    ];
    final summary = BorrowingSummary.from(b, repayments);

    // One month of accrual on ₹10,236 at 2%/mo ≈ ₹204.72 (the ₹10,500 lands
    // before the second month's accrual); the ₹236 financed fee's share is
    // 236/10,236 × 204.72 ≈ ₹4.72. Sourcing the row from wastedSoFar
    // (max(0, 10,500 − 10,000) = ₹500 here) would have shown
    // 236/10,236 × 500 ≈ ₹11.53 — ~2.4× the truth.
    final expected = expectedFeeShare(b, repayments);
    expect(expected, closeTo(4.72, 0.05));
    expect(summary.accruedInterest, closeTo(204.72, 0.05));

    await tester.pumpWidget(_app('loan-ff', summary));
    await tester.pumpAndSettle();

    expect(find.text('Interest on the financed fee'), findsOneWidget);
    expect(find.text(Money.format(expected)), findsOneWidget);
  });

  testWidgets(
      'fee-financed loan with no repayments still shows the row once '
      'interest has accrued', (tester) async {
    // The original defect: wastedSoFar is 0 until the user repays more than
    // the principal, so a fresh-but-accruing loan wrongly hid the row (and a
    // repaid one scaled it off repayments instead of accrual).
    final b =
        feeFinancedLoan(DateTime.now().subtract(const Duration(days: 45)));
    final summary = BorrowingSummary.from(b, const []);
    expect(summary.wastedSoFar, 0);
    expect(summary.accruedInterest, greaterThan(0));

    final expected = expectedFeeShare(b, const []);

    await tester.pumpWidget(_app('loan-ff', summary));
    await tester.pumpAndSettle();

    expect(find.text('Interest on the financed fee'), findsOneWidget);
    expect(find.text(Money.format(expected)), findsOneWidget);
  });

  testWidgets(
      'fee-financed loan with no interest accrued (0% rate) hides the row',
      (tester) async {
    // Hiding is only correct when accrued interest is genuinely zero. (The
    // accrual engine charges each month's interest as the month opens, so
    // even a day-one loan at a positive rate already carries accrual — a 0%
    // loan is the honest zero-accrual case.)
    final b = feeFinancedLoan(
      DateTime.now().subtract(const Duration(days: 45)),
      ratePct: 0,
    );
    final summary = BorrowingSummary.from(b, const []);
    expect(summary.accruedInterest, 0);

    await tester.pumpWidget(_app('loan-ff', summary));
    await tester.pumpAndSettle();

    expect(find.text('Interest on the financed fee'), findsNothing);
  });
}
