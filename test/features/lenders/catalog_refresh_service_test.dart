import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/lenders/data/catalog_refresh_service.dart';
import 'package:recurring/features/lenders/data/catalog_remote_source.dart';
import 'package:recurring/features/lenders/data/lender_repository_impl.dart';
import 'package:recurring/features/lenders/domain/entities/lender.dart';

/// A scriptable catalog server. [version] and [items] are whatever the test
/// sets; [throwOnFetch] simulates the device being offline.
class FakeCatalogRemoteSource implements CatalogRemoteSource {
  FakeCatalogRemoteSource(this.version, this.items);

  int version;
  List<Lender> items;
  bool throwOnFetch = false;
  int versionCalls = 0;
  int catalogCalls = 0;

  @override
  Future<int> fetchVersion() async {
    versionCalls++;
    if (throwOnFetch) throw Exception('offline');
    return version;
  }

  @override
  Future<CatalogSnapshot> fetchCatalog() async {
    catalogCalls++;
    if (throwOnFetch) throw Exception('offline');
    return (version: version, items: items);
  }
}

void main() {
  late AppDatabase db;
  late LenderRepositoryImpl repo;
  late SharedPreferences prefs;

  Lender catalogEntry(String id, {double rate = 16, bool isMine = false}) => Lender(
        id: id,
        name: id,
        type: LenderType.card,
        typicalRatePct: rate,
        feeType: FeeType.percent,
        feeValue: 2,
        isMine: isMine,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = AppDatabase.memory();
    repo = LenderRepositoryImpl(db);
    await seedLendersIfEmpty(db);
  });
  tearDown(() => db.close());

  test('skips the catalog fetch when the server version is not newer', () async {
    await prefs.setInt('catalog_version', 5);
    final remote = FakeCatalogRemoteSource(5, [catalogEntry('icici-card-emi', rate: 99)]);
    await CatalogRefreshService(remote, repo, prefs).refresh();

    expect(remote.versionCalls, 1);
    expect(remote.catalogCalls, 0); // never fetched the heavy payload
    final icici = await repo.getById('icici-card-emi');
    expect(icici!.typicalRatePct, isNot(99)); // untouched
  });

  test('applies newer server terms to a built-in and records the version', () async {
    final remote = FakeCatalogRemoteSource(7, [catalogEntry('icici-card-emi', rate: 13.5)]);
    await CatalogRefreshService(remote, repo, prefs).refresh();

    final icici = await repo.getById('icici-card-emi');
    expect(icici!.typicalRatePct, 13.5);
    expect(prefs.getInt('catalog_version'), 7);
  });

  test('preserves local isMine even though the catalog reports isMine=false', () async {
    // The seed marks icici-amazon-pay as the user's card.
    expect((await repo.getById('icici-amazon-pay'))!.isMine, isTrue);

    final remote = FakeCatalogRemoteSource(
      7,
      [catalogEntry('icici-amazon-pay', rate: 15.99, isMine: false)],
    );
    await CatalogRefreshService(remote, repo, prefs).refresh();

    final card = await repo.getById('icici-amazon-pay');
    expect(card!.isMine, isTrue); // ownership stayed local
    expect(card.typicalRatePct, 15.99); // terms refreshed
  });

  test('adds a brand-new server issuer not shipped in the seed', () async {
    final remote = FakeCatalogRemoteSource(7, [catalogEntry('yesbank-card-emi', rate: 17)]);
    await CatalogRefreshService(remote, repo, prefs).refresh();

    final added = await repo.getById('yesbank-card-emi');
    expect(added, isNotNull);
    expect(added!.isMine, isFalse);
  });

  test('removes a retired built-in but never a user card or user-added lender', () async {
    // A lender the user added (id outside the catalog) and marked as theirs.
    await repo.upsert(catalogEntry('my-custom-lender', isMine: true));

    // Server drops icici-card-emi (a shipped catalog entry) from the active set.
    final remote = FakeCatalogRemoteSource(7, [catalogEntry('hdfc-card-emi')]);
    await CatalogRefreshService(remote, repo, prefs).refresh();

    expect(await repo.getById('icici-card-emi'), isNull); // retired built-in gone
    expect(await repo.getById('my-custom-lender'), isNotNull); // user data safe
    expect((await repo.getById('icici-amazon-pay'))!.isMine, isTrue); // user card safe
  });

  test('offline leaves the seeded catalog untouched and version unadvanced', () async {
    final remote = FakeCatalogRemoteSource(7, [catalogEntry('icici-card-emi', rate: 99)])
      ..throwOnFetch = true;
    await CatalogRefreshService(remote, repo, prefs).refresh();

    final icici = await repo.getById('icici-card-emi');
    expect(icici!.typicalRatePct, isNot(99));
    expect(prefs.getInt('catalog_version'), isNull); // not advanced
  });

  test('an empty payload never wipes the catalog', () async {
    final remote = FakeCatalogRemoteSource(7, const []);
    await CatalogRefreshService(remote, repo, prefs).refresh();

    final all = await repo.watchAll().first;
    expect(all, hasLength(20)); // seed intact
    expect(prefs.getInt('catalog_version'), isNull);
  });
}
