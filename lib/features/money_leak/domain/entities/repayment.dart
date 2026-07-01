/// A single payment made against a [Borrowing] — one line in the ledger.
class Repayment {
  const Repayment({
    required this.id,
    required this.borrowingId,
    required this.amount,
    required this.date,
    this.installmentNo,
    this.note,
  });

  final String id;
  final String borrowingId;
  final double amount;
  final DateTime date;

  /// The 1-based EMI installment this payment settles, when the borrowing is a
  /// [BorrowingKind.fixedEmi]. Null for free flexible-loan payments.
  final int? installmentNo;
  final String? note;

  Repayment copyWith({double? amount, DateTime? date, int? installmentNo, String? note}) {
    return Repayment(
      id: id,
      borrowingId: borrowingId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      installmentNo: installmentNo ?? this.installmentNo,
      note: note ?? this.note,
    );
  }
}
