import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/lender.dart';
import '../domain/repositories/lender_repository.dart';
import 'lender_mapper.dart';
import 'lender_seed.dart';

class LenderRepositoryImpl implements LenderRepository {
  LenderRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Lender>> watchAll() {
    final query = _db.select(_db.lenders)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isMine, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.name),
      ]);
    return query.watch().map((rows) => rows.map(lenderFromRow).toList());
  }

  @override
  Stream<List<Lender>> watchMine() {
    final query = _db.select(_db.lenders)
      ..where((t) => t.isMine.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return query.watch().map((rows) => rows.map(lenderFromRow).toList());
  }

  @override
  Future<Lender?> getById(String id) async {
    final row = await (_db.select(_db.lenders)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : lenderFromRow(row);
  }

  @override
  Future<void> upsert(Lender lender) {
    return _db
        .into(_db.lenders)
        .insertOnConflictUpdate(lenderToCompanion(lender));
  }

  @override
  Future<void> delete(String id) {
    return (_db.delete(_db.lenders)..where((t) => t.id.equals(id))).go();
  }
}

/// Inserts the default catalog the first time the app runs.
Future<void> seedLendersIfEmpty(AppDatabase db) async {
  final existing = await db.select(db.lenders).get();
  if (existing.isNotEmpty) return;
  await db.batch((b) {
    b.insertAll(db.lenders, kSeedLenders.map(lenderToCompanion).toList());
  });
}

/// Upserts the seed catalog, refreshing rates/fees for the built-in lenders
/// (matched by id) while leaving any user-added lenders untouched. Used when
/// the seed data version changes.
Future<void> reseedLenders(AppDatabase db) async {
  await db.batch((b) {
    for (final lender in kSeedLenders) {
      b.insert(
        db.lenders,
        lenderToCompanion(lender),
        onConflict: DoUpdate((_) => lenderToCompanion(lender)),
      );
    }
  });
}
