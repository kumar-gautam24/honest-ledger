import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/cards/data/card_remote_source.dart';
import 'package:recurring/features/cards/data/card_repository_impl.dart';
import 'package:recurring/features/cards/data/synced_card_repository.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';

CardAccount _card({String id = 'c1'}) => CardAccount(
      id: id,
      lenderId: 'hdfc-swiggy',
      name: 'HDFC Swiggy',
      statementDay: 5,
      dueDay: 25,
      creditLimit: 200000,
      createdAt: DateTime(2026, 1, 1),
    );

CardStatement _statement({String id = 's1', String cardId = 'c1'}) =>
    CardStatement(
      id: id,
      cardId: cardId,
      cycleMonth: DateTime(2026, 7, 1),
      statementAmount: 12500.75,
      dueDate: DateTime(2026, 7, 25),
    );

class _FakeRemote implements CardRemoteSource {
  final pushedCards = <String>[];
  final pushedStatements = <String>[];
  List<CardAccount> cards = [];
  Map<String, List<CardStatement>> statements = {};
  bool throwOnPush = false;

  @override
  Future<List<CardAccount>> fetchCards() async => cards;
  @override
  Future<List<CardStatement>> fetchStatements(String cardId) async =>
      statements[cardId] ?? [];
  @override
  Future<void> pushCard(CardAccount c) async {
    if (throwOnPush) throw Exception('down');
    pushedCards.add(c.id);
  }

  @override
  Future<void> deleteCard(String id) async {}
  @override
  Future<void> pushStatement(CardStatement s) async =>
      pushedStatements.add(s.id);
  @override
  Future<void> deleteStatement(String id) async {}
}

class _Tokens implements AuthTokenStore {
  _Tokens({this.signedIn = false});
  bool signedIn;
  @override
  bool get isSignedIn => signedIn;
  @override
  String? get accessToken => signedIn ? 'a' : null;
  @override
  String? get refreshToken => signedIn ? 'r' : null;
  @override
  String? get email => null;
  @override
  Future<void> save({required String accessToken, required String refreshToken, required String email}) async {}
  @override
  Future<void> updateAccessToken(String accessToken) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  test('card and statement round-trip through JSON with paise', () {
    expect(cardToJson(_card())['credit_limit_paise'], 20000000);
    final sj = statementToJson(_statement());
    expect(sj['statement_amount_paise'], 1250075);
    final backCard = cardFromJson({...cardToJson(_card()), 'server_seq': 1});
    expect(backCard.creditLimit, 200000);
    final backStmt =
        statementFromJson({...sj, 'card_id': 'c1', 'server_seq': 1});
    expect(backStmt.statementAmount, 12500.75);
  });

  group('composite', () {
    late AppDatabase db;
    late CardRepositoryImpl local;
    late _FakeRemote remote;
    setUp(() {
      db = AppDatabase.memory();
      local = CardRepositoryImpl(db);
      remote = _FakeRemote();
    });
    tearDown(() => db.close());

    test('signed out writes local only', () async {
      final repo = SyncedCardRepository(local, remote, _Tokens());
      await repo.upsertCard(_card());
      await Future<void>.delayed(Duration.zero);
      expect((await repo.watchCards().first), hasLength(1));
      expect(remote.pushedCards, isEmpty);
    });

    test('signed in pushes card and statement', () async {
      final repo = SyncedCardRepository(local, remote, _Tokens(signedIn: true));
      await repo.upsertCard(_card());
      await repo.upsertStatement(_statement());
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushedCards, ['c1']);
      expect(remote.pushedStatements, ['s1']);
    });

    test('push failure keeps local intact', () async {
      remote.throwOnPush = true;
      final repo = SyncedCardRepository(local, remote, _Tokens(signedIn: true));
      await repo.upsertCard(_card());
      await Future<void>.delayed(Duration.zero);
      expect((await repo.watchCards().first), hasLength(1));
    });

    test('pushToCloud back-fills local cards AND statements', () async {
      final signedOut = SyncedCardRepository(local, remote, _Tokens());
      await signedOut.upsertCard(_card());
      await signedOut.upsertStatement(_statement());
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushedCards, isEmpty);

      final repo = SyncedCardRepository(local, remote, _Tokens(signedIn: true));
      await repo.pushToCloud();

      expect(remote.pushedCards, ['c1']);
      expect(remote.pushedStatements, ['s1']);
    });

    test('pullFromCloud loads cards and their statements', () async {
      remote.cards = [_card(id: 'server-card')];
      remote.statements['server-card'] = [
        _statement(id: 'server-stmt', cardId: 'server-card'),
      ];
      final repo = SyncedCardRepository(local, remote, _Tokens(signedIn: true));

      await repo.pullFromCloud();

      expect((await repo.watchCards().first).single.id, 'server-card');
      expect((await repo.watchStatements('server-card').first), hasLength(1));
    });
  });
}
