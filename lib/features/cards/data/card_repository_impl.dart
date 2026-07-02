import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/card_account.dart';
import '../domain/entities/card_statement.dart';
import '../domain/repositories/card_repository.dart';
import 'card_mapper.dart';

class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<CardAccount>> watchCards() {
    final query = _db.select(_db.cards).join([
      leftOuterJoin(_db.lenders, _db.lenders.id.equalsExp(_db.cards.lenderId)),
    ])
      ..orderBy([
        OrderingTerm(expression: _db.cards.isActive, mode: OrderingMode.desc),
        OrderingTerm(expression: _db.cards.createdAt),
      ]);
    return query.watch().map((rows) => [
          for (final row in rows)
            cardFromRow(
              row.readTable(_db.cards),
              name: row.readTableOrNull(_db.lenders)?.name ?? 'Card',
            ),
        ]);
  }

  @override
  Stream<List<CardStatement>> watchStatements(String cardId) {
    final query = _db.select(_db.cardStatements)
      ..where((t) => t.cardId.equals(cardId))
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.cycleMonth, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(statementFromRow).toList());
  }

  @override
  Stream<List<CardStatement>> watchAllStatements() {
    final query = _db.select(_db.cardStatements)
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.cycleMonth, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(statementFromRow).toList());
  }

  @override
  Future<void> upsertCard(CardAccount card) {
    return _db.into(_db.cards).insertOnConflictUpdate(cardToCompanion(card));
  }

  @override
  Future<void> deleteCard(String id) {
    return (_db.delete(_db.cards)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> upsertStatement(CardStatement statement) {
    // One statement per (card, cycle): replace whatever row holds that cycle,
    // regardless of its id.
    return _db.transaction(() async {
      await (_db.delete(_db.cardStatements)
            ..where((t) =>
                t.cardId.equals(statement.cardId) &
                t.cycleMonth.equals(statement.cycleMonth)))
          .go();
      await _db
          .into(_db.cardStatements)
          .insert(statementToCompanion(statement));
    });
  }

  @override
  Future<void> deleteStatement(String id) {
    return (_db.delete(_db.cardStatements)..where((t) => t.id.equals(id)))
        .go();
  }
}
