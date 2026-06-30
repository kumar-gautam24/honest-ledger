import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/recurring_item.dart';
import '../../domain/entities/recurring_stats.dart';
import '../../domain/repositories/recurring_repository.dart';

part 'recurring_providers.g.dart';

@riverpod
RecurringRepository recurringRepository(Ref ref) => sl<RecurringRepository>();

@riverpod
Stream<List<RecurringItem>> recurringItems(Ref ref) =>
    ref.watch(recurringRepositoryProvider).watchAll();

@riverpod
RecurringStats recurringStats(Ref ref) {
  final items = ref.watch(recurringItemsProvider);
  return items.maybeWhen(
    data: RecurringStats.from,
    orElse: () => RecurringStats.empty,
  );
}
