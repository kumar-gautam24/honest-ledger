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
