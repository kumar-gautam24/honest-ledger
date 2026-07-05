import 'dart:async';

import '../../../core/api/auth_token_store.dart';
import '../../../core/api/cloud_backed_repository.dart';
import '../domain/entities/borrowing.dart';
import '../domain/entities/borrowing_summary.dart';
import '../domain/entities/repayment.dart';
import '../domain/repositories/borrowing_repository.dart';
import 'borrowing_remote_source.dart';

/// Composes the local Drift repository with the API. Reads stay local (instant,
/// reactive, offline). Writes go local first — the UI updates immediately — then
/// push to the backend in the background, best-effort. `pullFromCloud` fetches
/// server rows into the local cache, where the existing streams pick them up.
class SyncedBorrowingRepository
    implements BorrowingRepository, CloudBackedRepository {
  SyncedBorrowingRepository(this._local, this._remote, this._tokens);

  final BorrowingRepository _local;
  final BorrowingRemoteSource _remote;
  final AuthTokenStore _tokens;

  // Reads: always local.
  @override
  Stream<List<BorrowingSummary>> watchSummaries() => _local.watchSummaries();

  @override
  Stream<BorrowingSummary?> watchSummary(String id) => _local.watchSummary(id);

  @override
  Stream<List<Repayment>> watchRepayments(String borrowingId) =>
      _local.watchRepayments(borrowingId);

  // Writes: local first (awaited), then background push.
  @override
  Future<void> upsertBorrowing(Borrowing borrowing) async {
    await _local.upsertBorrowing(borrowing);
    _push(() => _remote.pushBorrowing(borrowing));
  }

  @override
  Future<void> deleteBorrowing(String id) async {
    await _local.deleteBorrowing(id);
    _push(() => _remote.deleteBorrowing(id));
  }

  @override
  Future<void> addRepayment(Repayment repayment) async {
    await _local.addRepayment(repayment);
    _push(() => _remote.pushRepayment(repayment));
  }

  @override
  Future<void> deleteRepayment(String id) async {
    await _local.deleteRepayment(id);
    _push(() => _remote.deleteRepayment(id));
  }

  @override
  Future<void> pushToCloud() async {
    final summaries = await _local.watchSummaries().first;
    for (final summary in summaries) {
      // Borrowing first: its repayments 404 on the server without a parent.
      await _remote.pushBorrowing(summary.borrowing);
      final repayments = await _local.watchRepayments(summary.borrowing.id).first;
      for (final repayment in repayments) {
        await _remote.pushRepayment(repayment);
      }
    }
  }

  @override
  Future<void> pullFromCloud() async {
    final borrowings = await _remote.fetchBorrowings();
    for (final borrowing in borrowings) {
      await _local.upsertBorrowing(borrowing);
      final repayments = await _remote.fetchRepayments(borrowing.id);
      for (final repayment in repayments) {
        await _local.addRepayment(repayment);
      }
    }
  }

  /// Fire-and-forget remote write: never blocks the UI, never throws. Skipped
  /// entirely when signed out. Failures are swallowed — the local cache is truth.
  void _push(Future<void> Function() op) {
    if (!_tokens.isSignedIn) return;
    unawaited(op().catchError((Object _) {}));
  }
}
