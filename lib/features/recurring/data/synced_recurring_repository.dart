import 'dart:async';

import '../../../core/api/auth_token_store.dart';
import '../../../core/api/cloud_backed_repository.dart';
import '../domain/entities/recurring_item.dart';
import '../domain/repositories/recurring_repository.dart';
import 'recurring_remote_source.dart';

/// Local-first composite for recurring items: reads from Drift, writes local then
/// best-effort push, pulls server rows into the cache. See
/// SyncedBorrowingRepository for the pattern.
class SyncedRecurringRepository
    implements RecurringRepository, CloudBackedRepository {
  SyncedRecurringRepository(this._local, this._remote, this._tokens);

  final RecurringRepository _local;
  final RecurringRemoteSource _remote;
  final AuthTokenStore _tokens;

  @override
  Stream<List<RecurringItem>> watchAll() => _local.watchAll();

  @override
  Future<void> upsert(RecurringItem item) async {
    await _local.upsert(item);
    _push(() => _remote.push(item));
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    _push(() => _remote.delete(id));
  }

  @override
  Future<void> pushToCloud() async {
    final items = await _local.watchAll().first;
    for (final item in items) {
      await _remote.push(item);
    }
  }

  @override
  Future<void> pullFromCloud() async {
    final items = await _remote.fetchAll();
    for (final item in items) {
      await _local.upsert(item);
    }
  }

  void _push(Future<void> Function() op) {
    if (!_tokens.isSignedIn) return;
    unawaited(op().catchError((Object _) {}));
  }
}
