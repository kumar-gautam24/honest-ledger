import '../../../../core/utils/finance_math.dart';

enum BorrowingStatus {
  active('Active'),
  closed('Closed');

  const BorrowingStatus(this.label);
  final String label;
}

/// Whether repayments follow a fixed installment schedule or are made freely.
///
/// [fixedEmi] — a structured EMI: a schedule of exact monthly installments the
/// user ticks off (a card EMI, a consumer-finance plan).
/// [flexibleLoan] — a revolving/short loan (Slice, a quick advance): pay any
/// amount above a [Borrowing.minPayment], no maximum; interest accrues on the
/// outstanding balance, so paying more saves interest.
enum BorrowingKind {
  fixedEmi('EMI'),
  flexibleLoan('Loan');

  const BorrowingKind(this.label);
  final String label;

  bool get isEmi => this == BorrowingKind.fixedEmi;
}

/// A single thing the user borrowed: a Slice draw, a card EMI, a quick loan.
/// Repayments are tracked separately in the ledger.
class Borrowing {
  const Borrowing({
    required this.id,
    required this.title,
    required this.lenderName,
    required this.principal,
    required this.startDate,
    required this.createdAt,
    this.kind = BorrowingKind.flexibleLoan,
    this.lenderId,
    this.processingFee = 0,
    this.gstOnFee = 0,
    this.foreclosureFee = 0,
    this.gstOnInterest = false,
    this.isNoCostEmi = false,
    this.feeFinanced = false,
    this.interestRatePct = 0,
    this.rateType = RateType.reducing,
    this.tenureMonths = 0,
    this.minPayment = 0,
    this.status = BorrowingStatus.active,
    this.notes,
  });

  final String id;
  final String title;
  final BorrowingKind kind;
  final String? lenderId;
  final String lenderName;

  /// Amount actually borrowed.
  final double principal;
  final double processingFee;
  final double gstOnFee;

  /// Fee charged when a fixed EMI is closed early (foreclosure). 0 when the
  /// borrowing was never foreclosed.
  final double foreclosureFee;

  /// Whether 18% GST is levied on each installment's interest (as on Indian
  /// credit-card / consumer EMIs). Applies to [BorrowingKind.fixedEmi] only.
  final bool gstOnInterest;

  /// This fixed EMI was taken as a "No Cost EMI": the merchant's discount
  /// offsets the bank's interest, so installments are price/tenure and the
  /// leak is only GST-on-interest + fees. [BorrowingKind.fixedEmi] only.
  final bool isNoCostEmi;

  /// The processing fee (and its GST) was financed into the loan, so interest
  /// accrues on it too (Slice-style). [BorrowingKind.flexibleLoan] only.
  final bool feeFinanced;
  final double interestRatePct;
  final RateType rateType;

  /// Number of installments. Meaningful for [BorrowingKind.fixedEmi].
  final int tenureMonths;

  /// Smallest payment allowed for a [BorrowingKind.flexibleLoan] (no maximum).
  final double minPayment;
  final DateTime startDate;
  final BorrowingStatus status;
  final String? notes;
  final DateTime createdAt;

  bool get isClosed => status == BorrowingStatus.closed;
  bool get isEmi => kind.isEmi;

  Borrowing copyWith({
    String? title,
    BorrowingKind? kind,
    String? lenderId,
    String? lenderName,
    double? principal,
    double? processingFee,
    double? gstOnFee,
    double? foreclosureFee,
    bool? gstOnInterest,
    bool? isNoCostEmi,
    bool? feeFinanced,
    double? interestRatePct,
    RateType? rateType,
    int? tenureMonths,
    double? minPayment,
    DateTime? startDate,
    BorrowingStatus? status,
    String? notes,
  }) {
    return Borrowing(
      id: id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
      principal: principal ?? this.principal,
      processingFee: processingFee ?? this.processingFee,
      gstOnFee: gstOnFee ?? this.gstOnFee,
      foreclosureFee: foreclosureFee ?? this.foreclosureFee,
      gstOnInterest: gstOnInterest ?? this.gstOnInterest,
      isNoCostEmi: isNoCostEmi ?? this.isNoCostEmi,
      feeFinanced: feeFinanced ?? this.feeFinanced,
      interestRatePct: interestRatePct ?? this.interestRatePct,
      rateType: rateType ?? this.rateType,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      minPayment: minPayment ?? this.minPayment,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
