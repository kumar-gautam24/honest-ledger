import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/features/home/domain/entities/catch_up.dart';
import 'package:recurring/features/home/presentation/controllers/catch_up_controller.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/repositories/borrowing_repository.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';
import 'package:recurring/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  tearDown(() => sl<AppDatabase>().close());

  test('applying confirmed items logs repayments and advances recurring', () async {
    final borrowingRepo = sl<BorrowingRepository>();
    final recurringRepo = sl<RecurringRepository>();
    final now = DateTime(2026, 7, 15);

    // 12k @ 0% x 12 started 1 Apr → #1 (1 May), #2 (1 Jun) are arrears.
    await borrowingRepo.upsertBorrowing(Borrowing(
      id: 'b1',
      title: 'Phone EMI',
      lenderName: 'Test Bank',
      principal: 12000,
      startDate: DateTime(2026, 4, 1),
      createdAt: DateTime(2026, 4, 1),
      kind: BorrowingKind.fixedEmi,
      tenureMonths: 12,
    ));
    // Monthly sub two cycles behind.
    await recurringRepo.upsert(RecurringItem(
      id: 'r1',
      title: 'Netflix',
      amount: 499,
      nextDueDate: DateTime(2026, 5, 10),
      createdAt: DateTime(2026, 1, 1),
    ));

    final summaries = await borrowingRepo.watchSummaries().first;
    final items = await recurringRepo.watchAll().first;
    final catchUp = CatchUp.from(summaries: summaries, items: items, now: now);
    expect(catchUp.items, hasLength(4));

    await applyCatchUp(catchUp.items);

    // Repayments logged against installments 1 & 2, dated on their due dates.
    final repayments = await borrowingRepo.watchRepayments('b1').first;
    expect(repayments, hasLength(2));
    expect(
      repayments.map((r) => r.installmentNo).toSet(),
      {1, 2},
    );
    expect(
      repayments.map((r) => r.date).toSet(),
      {DateTime(2026, 5, 1), DateTime(2026, 6, 1)},
    );

    // Recurring advanced two cycles: 10 May → 10 Jul.
    final after = await recurringRepo.watchAll().first;
    expect(after.single.nextDueDate, DateTime(2026, 7, 10));

    // Arrears are cleared.
    final refreshed = CatchUp.from(
      summaries: await borrowingRepo.watchSummaries().first,
      items: after,
      now: now,
    );
    expect(refreshed.isEmpty, isTrue);
  });

  test('unchecked items are left in arrears', () async {
    final recurringRepo = sl<RecurringRepository>();
    await recurringRepo.upsert(RecurringItem(
      id: 'r1',
      title: 'Netflix',
      amount: 499,
      nextDueDate: DateTime(2026, 5, 10),
      createdAt: DateTime(2026, 1, 1),
    ));
    final items = await recurringRepo.watchAll().first;
    final catchUp = CatchUp.from(
      summaries: const [],
      items: items,
      now: DateTime(2026, 7, 15),
    );
    // Confirm only the first missed cycle.
    await applyCatchUp([catchUp.items.first]);

    final after = await recurringRepo.watchAll().first;
    expect(after.single.nextDueDate, DateTime(2026, 6, 10));
  });
}
