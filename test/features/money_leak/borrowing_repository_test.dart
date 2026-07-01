import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/money_leak/data/borrowing_repository_impl.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';

Borrowing _slice() => Borrowing(
      id: 'b1',
      title: 'Phone on Slice',
      lenderName: 'slice',
      principal: 10000,
      interestRatePct: 36,
      tenureMonths: 9,
      processingFee: 800,
      gstOnFee: 144,
      startDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late AppDatabase db;
  late BorrowingRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = BorrowingRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('repaying ₹15k on a ₹10k borrowing shows ₹5k wasted', () async {
    await repo.upsertBorrowing(_slice());
    await repo.addRepayment(Repayment(
      id: 'r1',
      borrowingId: 'b1',
      amount: 8000,
      date: DateTime(2026, 2, 1),
    ));
    await repo.addRepayment(Repayment(
      id: 'r2',
      borrowingId: 'b1',
      amount: 7000,
      date: DateTime(2026, 3, 1),
    ));

    final summaries = await repo.watchSummaries().first;
    expect(summaries, hasLength(1));

    final s = summaries.first;
    expect(s.totalRepaid, 15000);
    expect(s.wastedSoFar, 5000);
    expect(s.repayments, hasLength(2));
  });

  test('lifetime stats aggregate across borrowings', () async {
    await repo.upsertBorrowing(_slice());
    await repo.upsertBorrowing(Borrowing(
      id: 'b2',
      title: 'mPokket loan',
      lenderName: 'mPokket',
      principal: 5000,
      startDate: DateTime(2026, 2, 1),
      createdAt: DateTime(2026, 2, 1),
    ));
    await repo.addRepayment(Repayment(
      id: 'r1',
      borrowingId: 'b1',
      amount: 15000,
      date: DateTime(2026, 4, 1),
    ));

    final stats = LifetimeStats.from(await repo.watchSummaries().first);
    expect(stats.count, 2);
    expect(stats.totalBorrowed, 15000); // 10000 + 5000
    expect(stats.totalRepaid, 15000);
    expect(stats.totalWasted, 5000);
  });

  test('a fixed EMI tracks installments paid as N of tenure', () async {
    await repo.upsertBorrowing(Borrowing(
      id: 'e1',
      title: 'MacBook',
      kind: BorrowingKind.fixedEmi,
      lenderName: 'ICICI',
      principal: 120000,
      interestRatePct: 15,
      tenureMonths: 12,
      gstOnInterest: true,
      startDate: DateTime(2026, 1, 10),
      createdAt: DateTime(2026, 1, 10),
    ));
    final schedule = (await repo.watchSummaries().first).first.schedule;
    await repo.addRepayment(Repayment(
      id: 'p1',
      borrowingId: 'e1',
      amount: schedule.first.total,
      date: DateTime(2026, 2, 10),
      installmentNo: 1,
    ));

    final s = (await repo.watchSummaries().first).first;
    expect(s.isEmi, isTrue);
    expect(s.totalInstallments, 12);
    expect(s.paidInstallments, 1);
    expect(s.installmentLabel, '1/12');
    expect(s.isInstallmentPaid(1), isTrue);
    expect(s.nextDueInstallment?.number, 2);
  });

  test('a flexible loan accrues interest and repayments reduce it', () async {
    Borrowing loan() => Borrowing(
          id: 'l1',
          title: 'Slice draw',
          kind: BorrowingKind.flexibleLoan,
          lenderName: 'slice',
          principal: 20000,
          interestRatePct: 36,
          minPayment: 1000,
          startDate: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        );
    await repo.upsertBorrowing(loan());

    final before = (await repo.watchSummaries().first).first;
    expect(before.isEmi, isFalse);
    expect(before.minDue, 1000);
    expect(before.outstanding, greaterThan(0));

    await repo.addRepayment(Repayment(
      id: 'lp1',
      borrowingId: 'l1',
      amount: 8000,
      date: DateTime(2026, 2, 1),
    ));
    final after = (await repo.watchSummaries().first).first;
    expect(after.outstanding, lessThan(before.outstanding));
  });

  test('deleting a borrowing cascades its repayments', () async {
    await repo.upsertBorrowing(_slice());
    await repo.addRepayment(Repayment(
      id: 'r1',
      borrowingId: 'b1',
      amount: 1000,
      date: DateTime(2026, 2, 1),
    ));

    await repo.deleteBorrowing('b1');

    expect(await repo.watchSummaries().first, isEmpty);
    expect(await repo.watchRepayments('b1').first, isEmpty);
  });
}
