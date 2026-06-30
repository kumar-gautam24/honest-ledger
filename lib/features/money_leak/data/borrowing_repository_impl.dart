import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/entities/borrowing.dart';
import '../domain/entities/borrowing_summary.dart';
import '../domain/entities/repayment.dart';
import '../domain/repositories/borrowing_repository.dart';
import 'borrowing_mapper.dart';

class BorrowingRepositoryImpl implements BorrowingRepository {
  BorrowingRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<BorrowingSummary>> watchSummaries() {
    final query = _db.select(_db.borrowings).join([
      leftOuterJoin(
        _db.repayments,
        _db.repayments.borrowingId.equalsExp(_db.borrowings.id),
      ),
    ]);

    return query.watch().map((rows) {
      final byId = <String, _Aggregate>{};
      for (final row in rows) {
        final bRow = row.readTable(_db.borrowings);
        final agg = byId.putIfAbsent(
          bRow.id,
          () => _Aggregate(borrowingFromRow(bRow)),
        );
        final rRow = row.readTableOrNull(_db.repayments);
        if (rRow != null) agg.repayments.add(repaymentFromRow(rRow));
      }

      final summaries = byId.values
          .map((a) => BorrowingSummary.from(a.borrowing, a.repayments))
          .toList()
        ..sort(
          (x, y) => y.borrowing.createdAt.compareTo(x.borrowing.createdAt),
        );
      return summaries;
    });
  }

  @override
  Stream<BorrowingSummary?> watchSummary(String borrowingId) {
    return watchSummaries().map((list) {
      for (final s in list) {
        if (s.borrowing.id == borrowingId) return s;
      }
      return null;
    });
  }

  @override
  Stream<List<Repayment>> watchRepayments(String borrowingId) {
    final query = _db.select(_db.repayments)
      ..where((t) => t.borrowingId.equals(borrowingId))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map(repaymentFromRow).toList());
  }

  @override
  Future<void> upsertBorrowing(Borrowing borrowing) {
    return _db
        .into(_db.borrowings)
        .insertOnConflictUpdate(borrowingToCompanion(borrowing));
  }

  @override
  Future<void> deleteBorrowing(String id) {
    return (_db.delete(_db.borrowings)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> addRepayment(Repayment repayment) {
    return _db
        .into(_db.repayments)
        .insertOnConflictUpdate(repaymentToCompanion(repayment));
  }

  @override
  Future<void> deleteRepayment(String id) {
    return (_db.delete(_db.repayments)..where((t) => t.id.equals(id))).go();
  }
}

class _Aggregate {
  _Aggregate(this.borrowing);
  final Borrowing borrowing;
  final List<Repayment> repayments = [];
}
