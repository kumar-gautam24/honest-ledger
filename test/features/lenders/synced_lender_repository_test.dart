import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/lenders/data/lender_remote_source.dart';
import 'package:recurring/features/lenders/data/lender_repository_impl.dart';
import 'package:recurring/features/lenders/data/synced_lender_repository.dart';
import 'package:recurring/features/lenders/domain/entities/lender.dart';

Lender _custom({String id = 'my-card'}) => Lender(
      id: id,
      name: 'My Credit Union',
      type: LenderType.card,
      typicalRatePct: 18,
      feeType: FeeType.percent,
      feeValue: 2.5,
      feeCap: 299,
      isMine: true,
    );

class _FakeRemote implements LenderRemoteSource {
  final pushed = <String>[];
  final deleted = <String>[];
  List<Lender> toReturn = [];
  @override
  Future<List<Lender>> fetchAll() async => toReturn;
  @override
  Future<void> push(Lender l) async => pushed.add(l.id);
  @override
  Future<void> delete(String id) async => deleted.add(id);
}

class _Tokens implements AuthTokenStore {
  _Tokens({this.signedIn = true});
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
  test('lender round-trips through JSON (config stays non-paise)', () {
    final json = lenderToJson(_custom());
    expect(json['fee_value'], 2.5);
    expect(json['fee_cap'], 299);
    expect(json['type'], 'card');
    final back = lenderFromJson({...json, 'server_seq': 1});
    expect(back.feeType, FeeType.percent);
    expect(back.isMine, isTrue);
  });

  group('composite', () {
    late AppDatabase db;
    late LenderRepositoryImpl local;
    late _FakeRemote remote;
    setUp(() {
      db = AppDatabase.memory();
      local = LenderRepositoryImpl(db);
      remote = _FakeRemote();
    });
    tearDown(() => db.close());

    test('a user-added lender pushes to the API', () async {
      final repo = SyncedLenderRepository(local, remote, _Tokens());
      await repo.upsert(_custom());
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushed, ['my-card']);
    });

    test('a built-in lender is NOT pushed (stays client-seeded)', () async {
      final repo = SyncedLenderRepository(local, remote, _Tokens());
      // 'slice' is a built-in seed id.
      await repo.upsert(_custom(id: 'slice'));
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushed, isEmpty);
    });

    test('deleting a built-in does not call the API', () async {
      final repo = SyncedLenderRepository(local, remote, _Tokens());
      await repo.delete('slice');
      await Future<void>.delayed(Duration.zero);
      expect(remote.deleted, isEmpty);
    });

    test('signed out never pushes', () async {
      final repo = SyncedLenderRepository(local, remote, _Tokens(signedIn: false));
      await repo.upsert(_custom());
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushed, isEmpty);
    });

    test('pushToCloud back-fills user lenders and skips built-ins', () async {
      final signedOut = SyncedLenderRepository(local, remote, _Tokens(signedIn: false));
      await signedOut.upsert(_custom(id: 'my-card'));
      await signedOut.upsert(_custom(id: 'slice')); // a built-in seed id
      await Future<void>.delayed(Duration.zero);
      expect(remote.pushed, isEmpty);

      final repo = SyncedLenderRepository(local, remote, _Tokens());
      await repo.pushToCloud();

      expect(remote.pushed, ['my-card']);
    });

    test('pullFromCloud loads custom lenders locally', () async {
      remote.toReturn = [_custom(id: 'server-lender')];
      final repo = SyncedLenderRepository(local, remote, _Tokens());
      await repo.pullFromCloud();
      final loaded = await repo.getById('server-lender');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'My Credit Union');
    });
  });
}
