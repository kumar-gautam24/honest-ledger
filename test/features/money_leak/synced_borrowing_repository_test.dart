import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/money_leak/data/borrowing_remote_source.dart';
import 'package:recurring/features/money_leak/data/borrowing_repository_impl.dart';
import 'package:recurring/features/money_leak/data/synced_borrowing_repository.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';

Borrowing _borrowing({String id = 'b1'}) => Borrowing(
      id: id,
      title: 'Phone on Slice',
      lenderId: 'slice',
      lenderName: 'slice',
      kind: BorrowingKind.fixedEmi,
      principal: 10000.50,
      processingFee: 800,
      gstOnFee: 144,
      interestRatePct: 36,
      tenureMonths: 9,
      startDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
    );

/// Records pushes/deletes and serves canned fetches.
class _FakeRemote implements BorrowingRemoteSource {
  final pushed = <String>[];
  final deleted = <String>[];
  final pushedRepayments = <String>[];
  List<Borrowing> toReturn = [];
  Map<String, List<Repayment>> repaymentsByBorrowing = {};
  bool throwOnPush = false;

  @override
  Future<List<Borrowing>> fetchBorrowings() async => toReturn;

  @override
  Future<List<Repayment>> fetchRepayments(String borrowingId) async =>
      repaymentsByBorrowing[borrowingId] ?? [];

  @override
  Future<void> pushBorrowing(Borrowing b) async {
    if (throwOnPush) throw Exception('network down');
    pushed.add(b.id);
  }

  @override
  Future<void> deleteBorrowing(String id) async => deleted.add(id);

  @override
  Future<void> pushRepayment(Repayment r) async => pushedRepayments.add(r.id);

  @override
  Future<void> deleteRepayment(String id) async {}
}

class _FakeTokens implements AuthTokenStore {
  _FakeTokens({this.signedIn = false});
  bool signedIn;
  @override
  bool get isSignedIn => signedIn;
  @override
  String? get accessToken => signedIn ? 'a' : null;
  @override
  String? get refreshToken => signedIn ? 'r' : null;
  @override
  String? get email => signedIn ? 'a@b.com' : null;
  @override
  Future<void> save({required String accessToken, required String refreshToken, required String email}) async {}
  @override
  Future<void> updateAccessToken(String accessToken) async {}
  @override
  Future<void> clear() async {}
}

void main() {
  group('mapping', () {
    test('borrowing round-trips through JSON with paise conversion', () {
      final json = borrowingToJson(_borrowing());
      expect(json['principal_paise'], 1000050); // 10000.50 -> paise
      expect(json['lender_id'], 'slice');
      expect(json['kind'], 'fixedEmi');

      final back = borrowingFromJson({
        ...json,
        'created_at': json['start_date'],
        'deleted_at': null,
        'server_seq': 1,
      });
      expect(back.principal, 10000.50);
      expect(back.kind, BorrowingKind.fixedEmi);
      expect(back.lenderId, 'slice');
    });

    test('repayment round-trips with paise', () {
      final r = Repayment(
        id: 'r1',
        borrowingId: 'b1',
        amount: 500.25,
        date: DateTime(2026, 2, 1),
        installmentNo: 2,
      );
      final json = repaymentToJson(r);
      expect(json['amount_paise'], 50025);
      final back = repaymentFromJson({...json, 'borrowing_id': 'b1'});
      expect(back.amount, 500.25);
      expect(back.installmentNo, 2);
    });
  });

  group('composite repository', () {
    late AppDatabase db;
    late BorrowingRepositoryImpl local;
    late _FakeRemote remote;

    setUp(() {
      db = AppDatabase.memory();
      local = BorrowingRepositoryImpl(db);
      remote = _FakeRemote();
    });
    tearDown(() => db.close());

    test('signed out: writes local only, never touches remote', () async {
      final repo = SyncedBorrowingRepository(local, remote, _FakeTokens());
      await repo.upsertBorrowing(_borrowing());
      await Future<void>.delayed(Duration.zero);

      final summaries = await repo.watchSummaries().first;
      expect(summaries, hasLength(1));
      expect(remote.pushed, isEmpty);
    });

    test('signed in: writes local AND pushes to remote', () async {
      final repo =
          SyncedBorrowingRepository(local, remote, _FakeTokens(signedIn: true));
      await repo.upsertBorrowing(_borrowing());
      await Future<void>.delayed(Duration.zero);

      expect((await repo.watchSummaries().first), hasLength(1));
      expect(remote.pushed, ['b1']);
    });

    test('push failure does not break the local save', () async {
      remote.throwOnPush = true;
      final repo =
          SyncedBorrowingRepository(local, remote, _FakeTokens(signedIn: true));

      await repo.upsertBorrowing(_borrowing()); // must not throw
      await Future<void>.delayed(Duration.zero);

      expect((await repo.watchSummaries().first), hasLength(1)); // local intact
    });

    test('pullFromCloud writes server rows into the local cache', () async {
      remote.toReturn = [_borrowing(id: 'server1')];
      remote.repaymentsByBorrowing['server1'] = [
        Repayment(id: 'rp1', borrowingId: 'server1', amount: 100, date: DateTime(2026, 3, 1)),
      ];
      final repo =
          SyncedBorrowingRepository(local, remote, _FakeTokens(signedIn: true));

      await repo.pullFromCloud();

      final summaries = await repo.watchSummaries().first;
      expect(summaries, hasLength(1));
      expect(summaries.first.borrowing.id, 'server1');
      final repayments = await repo.watchRepayments('server1').first;
      expect(repayments, hasLength(1));
    });
  });
}
