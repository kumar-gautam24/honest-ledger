import '../entities/borrowing.dart';
import '../entities/borrowing_summary.dart';
import '../entities/repayment.dart';

/// Read/write access to borrowings and their repayment ledgers.
abstract interface class BorrowingRepository {
  /// All borrowings with derived figures, newest first. Updates when either
  /// borrowings or repayments change.
  Stream<List<BorrowingSummary>> watchSummaries();

  Stream<BorrowingSummary?> watchSummary(String borrowingId);

  Stream<List<Repayment>> watchRepayments(String borrowingId);

  Future<void> upsertBorrowing(Borrowing borrowing);

  Future<void> deleteBorrowing(String id);

  Future<void> addRepayment(Repayment repayment);

  Future<void> deleteRepayment(String id);
}
