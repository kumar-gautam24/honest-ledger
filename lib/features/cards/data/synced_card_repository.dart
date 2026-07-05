import 'dart:async';

import '../../../core/api/auth_token_store.dart';
import '../../../core/api/cloud_backed_repository.dart';
import '../domain/entities/card_account.dart';
import '../domain/entities/card_statement.dart';
import '../domain/repositories/card_repository.dart';
import 'card_remote_source.dart';

/// Local-first composite for cards + statements. Same pattern as
/// SyncedBorrowingRepository: local reads, local-first writes with best-effort
/// background push, and a cloud pull into the local cache.
class SyncedCardRepository implements CardRepository, CloudBackedRepository {
  SyncedCardRepository(this._local, this._remote, this._tokens);

  final CardRepository _local;
  final CardRemoteSource _remote;
  final AuthTokenStore _tokens;

  @override
  Stream<List<CardAccount>> watchCards() => _local.watchCards();

  @override
  Stream<List<CardStatement>> watchStatements(String cardId) =>
      _local.watchStatements(cardId);

  @override
  Stream<List<CardStatement>> watchAllStatements() =>
      _local.watchAllStatements();

  @override
  Future<void> upsertCard(CardAccount card) async {
    await _local.upsertCard(card);
    _push(() => _remote.pushCard(card));
  }

  @override
  Future<void> deleteCard(String id) async {
    await _local.deleteCard(id);
    _push(() => _remote.deleteCard(id));
  }

  @override
  Future<void> upsertStatement(CardStatement statement) async {
    await _local.upsertStatement(statement);
    _push(() => _remote.pushStatement(statement));
  }

  @override
  Future<void> deleteStatement(String id) async {
    await _local.deleteStatement(id);
    _push(() => _remote.deleteStatement(id));
  }

  @override
  Future<void> pushToCloud() async {
    // Cards first so their statements have a parent on the server.
    final cards = await _local.watchCards().first;
    for (final card in cards) {
      await _remote.pushCard(card);
    }
    final statements = await _local.watchAllStatements().first;
    for (final statement in statements) {
      await _remote.pushStatement(statement);
    }
  }

  @override
  Future<void> pullFromCloud() async {
    final cards = await _remote.fetchCards();
    for (final card in cards) {
      await _local.upsertCard(card);
      final statements = await _remote.fetchStatements(card.id);
      for (final statement in statements) {
        await _local.upsertStatement(statement);
      }
    }
  }

  void _push(Future<void> Function() op) {
    if (!_tokens.isSignedIn) return;
    unawaited(op().catchError((Object _) {}));
  }
}
