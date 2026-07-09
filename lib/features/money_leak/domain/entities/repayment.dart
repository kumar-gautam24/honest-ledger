/// What a ledger line represents.
///
/// [payment] — money that services the debt: it retires principal and can tick
/// off an installment.
/// [charge] — money the lender took on top (a late-payment penal charge, a
/// bounce fee). It is real cash gone, so it counts as waste, but it clears no
/// principal and settles no installment.
///
/// Charges are only ever entered by hand. The app never infers one from an
/// unticked installment: not opening the app is not the same as missing a
/// payment, and guessing would invent costs the user never paid.
enum RepaymentKind {
  payment('Payment'),
  charge('Charge');

  const RepaymentKind(this.label);
  final String label;

  bool get isCharge => this == RepaymentKind.charge;
}

/// A single line in a [Borrowing]'s ledger — a payment made, or a charge taken.
class Repayment {
  const Repayment({
    required this.id,
    required this.borrowingId,
    required this.amount,
    required this.date,
    this.kind = RepaymentKind.payment,
    this.installmentNo,
    this.note,
  });

  final String id;
  final String borrowingId;
  final double amount;
  final DateTime date;
  final RepaymentKind kind;

  /// The 1-based EMI installment this payment settles, when the borrowing is a
  /// [BorrowingKind.fixedEmi]. Null for free flexible-loan payments, and always
  /// null for a [RepaymentKind.charge].
  final int? installmentNo;
  final String? note;

  bool get isCharge => kind.isCharge;

  Repayment copyWith({
    double? amount,
    DateTime? date,
    RepaymentKind? kind,
    int? installmentNo,
    String? note,
  }) {
    return Repayment(
      id: id,
      borrowingId: borrowingId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      installmentNo: installmentNo ?? this.installmentNo,
      note: note ?? this.note,
    );
  }
}
