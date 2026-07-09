import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/lenders/data/lender_repository_impl.dart';
import 'package:recurring/features/lenders/data/lender_seed.dart';
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
    expect(all, hasLength(16));
  });

  test('sbi-card-emi has no fee floor: Flexipay is 1% capped at ₹2,000 '
      '(w.e.f. 23 Nov 2025), so a small booking pays 1%', () async {
    final sbi = await repo.getById('sbi-card-emi');
    expect(sbi, isNotNull);
    expect(sbi!.feeMin, isNull);
    expect(sbi.feeCap, 2000);

    final fee = FinanceMath.processingFee(
      principal: 5000,
      type: sbi.feeType,
      value: sbi.feeValue,
      cap: sbi.feeCap,
      min: sbi.feeMin,
    );
    expect(fee, 50); // 1% of 5,000 — no floor to lift it
  });

  test('reseed refreshing built-ins carries feeMin through the round trip', () async {
    await reseedLenders(db);
    final hdfc = await repo.getById('hdfc-card-emi');
    expect(hdfc!.feeMin, 149);
  });

  test('seed v5 carries foreclosure rules through the round trip', () async {
    await reseedLenders(db);
    // slice: free to foreclose (RBI 2025 Directions) but one extra day of
    // interest, and no GST since there is no fee to tax.
    final slice = await repo.getById('slice');
    expect(slice!.foreclosurePct, 0);
    expect(slice.foreclosureExtraInterestDays, 1);
    expect(slice.foreclosureGst, isFalse);
    // Axis: 3% or ₹300, whichever is higher, free within 7 days.
    final axis = await repo.getById('axis-card-emi');
    expect(axis!.foreclosurePct, 3);
    expect(axis.foreclosureMin, 300);
    expect(axis.foreclosureFreeWindowDays, 7);
    // HDFC: free within 30 days of booking.
    final hdfc = await repo.getById('hdfc-card-emi');
    expect(hdfc!.foreclosureFreeWindowDays, 30);
  });

  test('hdfc-card-emi carries a fee floor that threads through '
      'processingFee (1% of ₹5,000 = ₹50, floored to ₹149)', () async {
    final hdfc = await repo.getById('hdfc-card-emi');
    expect(hdfc, isNotNull);
    expect(hdfc!.feeMin, 149);

    final fee = FinanceMath.processingFee(
      principal: 5000,
      type: hdfc.feeType,
      value: 1,
      min: hdfc.feeMin,
    );
    expect(fee, 149);
  });

  test('seed v4 adds kotak and amex card-EMI entries', () {
    expect(kSeedLenders.map((l) => l.id), contains('kotak-card-emi'));
    expect(kSeedLenders.map((l) => l.id), contains('amex-card-emi'));
  });

  test('reseed refreshes built-in rates but keeps user-added lenders', () async {
    // User tweaks a built-in and adds their own lender.
    final slice = await repo.getById('slice');
    await repo.upsert(slice!.copyWith(typicalRatePct: 1));
    await repo.upsert(
      const Lender(id: 'mine', name: 'My NBFC', type: LenderType.nbfc),
    );

    await reseedLenders(db);

    // Refreshed to the rate verified against the user's own slice KFS.
    expect((await repo.getById('slice'))!.typicalRatePct, 31.15);
    expect(await repo.getById('mine'), isNotNull); // preserved
  });
}
