/// A single payment made against a [Borrowing] — one line in the ledger.
class Repayment {
  const Repayment({
    required this.id,
    required this.borrowingId,
    required this.amount,
    required this.date,
    this.note,
  });

  final String id;
  final String borrowingId;
  final double amount;
  final DateTime date;
  final String? note;
}
