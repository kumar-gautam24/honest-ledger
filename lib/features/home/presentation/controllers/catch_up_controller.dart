import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../money_leak/domain/entities/repayment.dart';
import '../../../money_leak/domain/repositories/borrowing_repository.dart';
import '../../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../../recurring/domain/repositories/recurring_repository.dart';
import '../../../recurring/presentation/controllers/recurring_providers.dart';
import '../../domain/entities/catch_up.dart';

part 'catch_up_controller.g.dart';

const _uuid = Uuid();

/// Everything that went past before this month without being logged.
@riverpod
CatchUp catchUp(Ref ref) {
  final borrowings =
      ref.watch(borrowingSummariesProvider).asData?.value ?? const [];
  final recurring = ref.watch(recurringItemsProvider).asData?.value ?? const [];
  return CatchUp.from(
    summaries: borrowings,
    items: recurring,
    now: DateTime.now(),
  );
}

/// Marks the confirmed missed occurrences as paid: EMI installments get real
/// ledger entries dated on their due dates (so interest and waste math stay
/// honest), recurring items advance one cycle per confirmed occurrence.
Future<void> applyCatchUp(List<CatchUpItem> confirmed) async {
  final borrowingRepo = sl<BorrowingRepository>();
  final recurringRepo = sl<RecurringRepository>();

  final advancesByItem = <String, int>{};
  for (final item in confirmed) {
    switch (item.source) {
      case CatchUpSource.emiInstallment:
        await borrowingRepo.addRepayment(Repayment(
          id: _uuid.v4(),
          borrowingId: item.sourceId,
          amount: item.amount,
          date: item.dueDate,
          installmentNo: item.installmentNo,
        ));
      case CatchUpSource.recurring:
        advancesByItem.update(item.sourceId, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  if (advancesByItem.isEmpty) return;
  final items = await recurringRepo.watchAll().first;
  for (final MapEntry(key: id, value: cycles) in advancesByItem.entries) {
    for (final item in items) {
      if (item.id != id) continue;
      var updated = item;
      for (var i = 0; i < cycles; i++) {
        updated = updated.copyWith(nextDueDate: updated.advanceDue());
      }
      await recurringRepo.upsert(updated);
    }
  }
}
