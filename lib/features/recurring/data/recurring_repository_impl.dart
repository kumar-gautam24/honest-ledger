import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/recurring_item.dart';
import '../domain/repositories/recurring_repository.dart';
import 'recurring_mapper.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  RecurringRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<RecurringItem>> watchAll() {
    final query = _db.select(_db.recurringItems)
      ..orderBy([
        (t) => OrderingTerm(expression: t.isActive, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.nextDueDate),
      ]);
    return query.watch().map((rows) => rows.map(recurringFromRow).toList());
  }

  @override
  Future<void> upsert(RecurringItem item) {
    return _db
        .into(_db.recurringItems)
        .insertOnConflictUpdate(recurringToCompanion(item));
  }

  @override
  Future<void> delete(String id) {
    return (_db.delete(_db.recurringItems)..where((t) => t.id.equals(id))).go();
  }
}
