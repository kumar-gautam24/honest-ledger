import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/cards/domain/repositories/card_repository.dart';
import 'package:recurring/features/lenders/domain/repositories/lender_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  tearDown(() => sl<AppDatabase>().close());

  Future<String> seededLenderId() async {
    final lenders = await sl<LenderRepository>().watchAll().first;
    return lenders.first.id;
  }

  test('card name resolves from the lender catalog', () async {
    final repo = sl<CardRepository>();
    final lenders = await sl<LenderRepository>().watchAll().first;
    final lender = lenders.first;

    await repo.upsertCard(CardAccount(
      id: 'c1',
      lenderId: lender.id,
      name: '', // stored name is irrelevant — catalog wins
      statementDay: 15,
      dueDay: 3,
      createdAt: DateTime(2026, 7, 1),
    ));

    final cards = await repo.watchCards().first;
    expect(cards.single.name, lender.name);
  });

  test('statement upsert replaces the same cycle', () async {
    final repo = sl<CardRepository>();
    await repo.upsertCard(CardAccount(
      id: 'c1',
      lenderId: await seededLenderId(),
      name: '',
      statementDay: 15,
      dueDay: 3,
      createdAt: DateTime(2026, 7, 1),
    ));

    CardStatement statement(double amount) => CardStatement(
          id: 's1',
          cardId: 'c1',
          cycleMonth: DateTime(2026, 7),
          statementAmount: amount,
          dueDate: DateTime(2026, 8, 3),
        );

    await repo.upsertStatement(statement(18400));
    await repo.upsertStatement(statement(19000));

    final statements = await repo.watchStatements('c1').first;
    expect(statements.single.statementAmount, 19000);
  });

  test('deleting a card cascades its statements', () async {
    final repo = sl<CardRepository>();
    await repo.upsertCard(CardAccount(
      id: 'c1',
      lenderId: await seededLenderId(),
      name: '',
      statementDay: 15,
      dueDay: 3,
      createdAt: DateTime(2026, 7, 1),
    ));
    await repo.upsertStatement(CardStatement(
      id: 's1',
      cardId: 'c1',
      cycleMonth: DateTime(2026, 7),
      statementAmount: 18400,
      dueDate: DateTime(2026, 8, 3),
    ));

    await repo.deleteCard('c1');

    expect(await repo.watchCards().first, isEmpty);
    expect(await repo.watchAllStatements().first, isEmpty);
  });
}
