import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/borrowing_summary.dart';
import '../../domain/repositories/borrowing_repository.dart';

part 'money_leak_providers.g.dart';

@riverpod
BorrowingRepository borrowingRepository(Ref ref) => sl<BorrowingRepository>();

@riverpod
Stream<List<BorrowingSummary>> borrowingSummaries(Ref ref) =>
    ref.watch(borrowingRepositoryProvider).watchSummaries();

@riverpod
Stream<BorrowingSummary?> borrowingSummary(Ref ref, String id) =>
    ref.watch(borrowingRepositoryProvider).watchSummary(id);

/// Lifetime roll-up derived from the summaries stream — drives the hero.
@riverpod
LifetimeStats lifetimeStats(Ref ref) {
  final summaries = ref.watch(borrowingSummariesProvider);
  return summaries.maybeWhen(
    data: LifetimeStats.from,
    orElse: () => LifetimeStats.empty,
  );
}
