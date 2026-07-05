import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/recurring/data/recurring_remote_source.dart';
import 'package:recurring/features/recurring/data/recurring_repository_impl.dart';
import 'package:recurring/features/recurring/data/synced_recurring_repository.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';

RecurringItem _item({String id = 'r1'}) => RecurringItem(
      id: id,
      title: 'Netflix',
      amount: 649.50,
      type: RecurringType.subscription,
      frequency: Frequency.monthly,
      nextDueDate: DateTime(2026, 8, 1),
      createdAt: DateTime(2026, 1, 1),
    );

class _FakeRemote implements RecurringRemoteSource {
  final pushed = <String>[];
  List<RecurringItem> toReturn = [];
  bool throwOnPush = false;
  @override
  Future<List<RecurringItem>> fetchAll() async => toReturn;
  @override
  Future<void> push(RecurringItem i) async {
    if (throwOnPush) throw Exception('down');
    pushed.add(i.id);
  }

  @override
  Future<void> delete(String id) async {}
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
  test('recurring item round-trips through JSON with paise', () {
    final json = recurringToJson(_item());
    expect(json['amount_paise'], 64950);
    expect(json['frequency'], 'monthly');
    final back = recurringFromJson({...json, 'deleted_at': null, 'server_seq': 1});
    expect(back.amount, 649.50);
    expect(back.type, RecurringType.subscription);
  });

  group('composite', () {
    late AppDatabase db;
    late RecurringRepositoryImpl local;
    late _FakeRemote remote;
    setUp(() {
      db = AppDatabase.memory();
      local = RecurringRepositoryImpl(db);
      remote = _FakeRemote();
    });
    tearDown(() => db.close());

    test('signed out writes local only', () async {
      final repo = SyncedRecurringRepository(local, remote, _Tokens());
      await repo.upsert(_item());
      await Future<void>.delayed(Duration.zero);
      expect((await repo.watchAll().first), hasLength(1));
      expect(remote.pushed, isEmpty);
    });

    test('signed in writes local and pushes', () async {
      final repo = SyncedRecurringRepository(local, remote, _Tokens(signedIn: true));
      await repo.upsert(_item());
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushed, ['r1']);
    });

    test('push failure keeps local intact', () async {
      remote.throwOnPush = true;
      final repo = SyncedRecurringRepository(local, remote, _Tokens(signedIn: true));
      await repo.upsert(_item());
      await Future<void>.delayed(Duration.zero);
      expect((await repo.watchAll().first), hasLength(1));
    });

    test('pushToCloud back-fills local items created while signed out',
        () async {
      final signedOut = SyncedRecurringRepository(local, remote, _Tokens());
      await signedOut.upsert(_item(id: 'r1'));
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushed, isEmpty);

      final repo =
          SyncedRecurringRepository(local, remote, _Tokens(signedIn: true));
      await repo.pushToCloud();

      expect(remote.pushed, ['r1']);
    });

    test('pullFromCloud loads server rows locally', () async {
      remote.toReturn = [_item(id: 'server1')];
      final repo = SyncedRecurringRepository(local, remote, _Tokens(signedIn: true));
      await repo.pullFromCloud();
      final all = await repo.watchAll().first;
      expect(all.single.id, 'server1');
    });
  });
}
