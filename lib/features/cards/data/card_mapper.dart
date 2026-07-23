import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/card_account.dart';
import '../domain/entities/card_statement.dart';

CardAccount cardFromRow(CardRow row, {required String name}) {
  return CardAccount(
    id: row.id,
    lenderId: row.lenderId,
    name: name,
    statementDay: row.statementDay,
    dueDay: row.dueDay,
    nickname: row.nickname,
    creditLimit: row.creditLimit,
    isActive: row.isActive,
    createdAt: row.createdAt,
  );
}

CardsCompanion cardToCompanion(CardAccount card) {
  return CardsCompanion(
    id: Value(card.id),
    lenderId: Value(card.lenderId),
    statementDay: Value(card.statementDay),
    dueDay: Value(card.dueDay),
    nickname: Value(card.nickname),
    creditLimit: Value(card.creditLimit),
    isActive: Value(card.isActive),
    createdAt: Value(card.createdAt),
  );
}

CardStatement statementFromRow(CardStatementRow row) {
  return CardStatement(
    id: row.id,
    cardId: row.cardId,
    cycleMonth: row.cycleMonth,
    statementAmount: row.statementAmount,
    dueDate: row.dueDate,
    paidAmount: row.paidAmount,
    paidDate: row.paidDate,
    notes: row.notes,
  );
}

CardStatementsCompanion statementToCompanion(CardStatement s) {
  return CardStatementsCompanion(
    id: Value(s.id),
    cardId: Value(s.cardId),
    cycleMonth: Value(s.cycleMonth),
    statementAmount: Value(s.statementAmount),
    dueDate: Value(s.dueDate),
    paidAmount: Value(s.paidAmount),
    paidDate: Value(s.paidDate),
    notes: Value(s.notes),
  );
}
