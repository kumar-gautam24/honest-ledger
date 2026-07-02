import '../entities/card_account.dart';
import '../entities/card_statement.dart';

/// Read/write access to cards and their monthly statements.
abstract interface class CardRepository {
  /// Active cards first; display names resolved from the lender catalog.
  Stream<List<CardAccount>> watchCards();

  /// Newest cycle first.
  Stream<List<CardStatement>> watchStatements(String cardId);

  Stream<List<CardStatement>> watchAllStatements();

  Future<void> upsertCard(CardAccount card);

  Future<void> deleteCard(String id);

  /// One statement per (card, cycle) — upserting the same cycle replaces it.
  Future<void> upsertStatement(CardStatement statement);

  Future<void> deleteStatement(String id);
}
