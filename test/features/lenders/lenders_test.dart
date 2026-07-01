import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/lenders/data/lender_repository_impl.dart';
import 'package:recurring/features/lenders/domain/entities/lender.dart';

void main() {
  late AppDatabase db;
  late LenderRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.memory();
    repo = LenderRepositoryImpl(db);
    await seedLendersIfEmpty(db);
  });
  tearDown(() => db.close());

  test('seeds the catalog with the five user cards', () async {
    final mine = await repo.watchMine().first;
    expect(mine, hasLength(5));
    expect(mine.every((l) => l.isMine), isTrue);
    expect(
      mine.map((l) => l.name),
      containsAll(['SBI Flipkart', 'HDFC Swiggy', 'ICICI Amazon Pay']),
    );
  });

  test('editing a lender rate persists', () async {
    final slice = await repo.getById('slice');
    expect(slice, isNotNull);

    await repo.upsert(slice!.copyWith(typicalRatePct: 42));

    final updated = await repo.getById('slice');
    expect(updated!.typicalRatePct, 42);
  });

  test('seeding is idempotent (only once)', () async {
    await seedLendersIfEmpty(db); // second call is a no-op
    final all = await repo.watchAll().first;
    expect(all, hasLength(14));
  });

  test('reseed refreshes built-in rates but keeps user-added lenders', () async {
    // User tweaks a built-in and adds their own lender.
    final slice = await repo.getById('slice');
    await repo.upsert(slice!.copyWith(typicalRatePct: 1));
    await repo.upsert(
      const Lender(id: 'mine', name: 'My NBFC', type: LenderType.nbfc),
    );

    await reseedLenders(db);

    expect((await repo.getById('slice'))!.typicalRatePct, 36); // refreshed
    expect(await repo.getById('mine'), isNotNull); // preserved
  });
}
