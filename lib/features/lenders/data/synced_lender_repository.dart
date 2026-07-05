import 'dart:async';

import '../../../core/api/auth_token_store.dart';
import '../../../core/api/cloud_backed_repository.dart';
import '../domain/entities/lender.dart';
import '../domain/repositories/lender_repository.dart';
import 'lender_remote_source.dart';
import 'lender_seed.dart';

/// Local-first composite for lenders. Only the user's CUSTOM lenders sync — the
/// built-in catalog ships with the app (and lives in the server's global catalog),
/// so pushes for built-in ids are skipped. Otherwise the usual pattern.
class SyncedLenderRepository
    implements LenderRepository, CloudBackedRepository {
  SyncedLenderRepository(this._local, this._remote, this._tokens);

  final LenderRepository _local;
  final LenderRemoteSource _remote;
  final AuthTokenStore _tokens;

  @override
  Stream<List<Lender>> watchAll() => _local.watchAll();

  @override
  Stream<List<Lender>> watchMine() => _local.watchMine();

  @override
  Future<Lender?> getById(String id) => _local.getById(id);

  @override
  Future<void> upsert(Lender lender) async {
    await _local.upsert(lender);
    if (!kSeedLenderIds.contains(lender.id)) {
      _push(() => _remote.push(lender));
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    if (!kSeedLenderIds.contains(id)) {
      _push(() => _remote.delete(id));
    }
  }

  @override
  Future<void> pushToCloud() async {
    // Only the user's custom lenders sync; the built-in catalog is server-side.
    final mine = await _local.watchMine().first;
    for (final lender in mine) {
      if (!kSeedLenderIds.contains(lender.id)) {
        await _remote.push(lender);
      }
    }
  }

  @override
  Future<void> pullFromCloud() async {
    final lenders = await _remote.fetchAll();
    for (final lender in lenders) {
      await _local.upsert(lender);
    }
  }

  void _push(Future<void> Function() op) {
    if (!_tokens.isSignedIn) return;
    unawaited(op().catchError((Object _) {}));
  }
}
