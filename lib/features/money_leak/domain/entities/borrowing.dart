import '../../../../core/utils/finance_math.dart';

enum BorrowingStatus {
  active('Active'),
  closed('Closed');

  const BorrowingStatus(this.label);
  final String label;
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
    this.lenderId,
    this.processingFee = 0,
    this.gstOnFee = 0,
    this.interestRatePct = 0,
    this.rateType = RateType.reducing,
    this.tenureMonths = 0,
    this.status = BorrowingStatus.active,
    this.notes,
  });

  final String id;
  final String title;
  final String? lenderId;
  final String lenderName;

  /// Amount actually borrowed.
  final double principal;
  final double processingFee;
  final double gstOnFee;
  final double interestRatePct;
  final RateType rateType;
  final int tenureMonths;
  final DateTime startDate;
  final BorrowingStatus status;
  final String? notes;
  final DateTime createdAt;

  bool get isClosed => status == BorrowingStatus.closed;

  Borrowing copyWith({
    String? title,
    String? lenderId,
    String? lenderName,
    double? principal,
    double? processingFee,
    double? gstOnFee,
    double? interestRatePct,
    RateType? rateType,
    int? tenureMonths,
    DateTime? startDate,
    BorrowingStatus? status,
    String? notes,
  }) {
    return Borrowing(
      id: id,
      title: title ?? this.title,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
      principal: principal ?? this.principal,
      processingFee: processingFee ?? this.processingFee,
      gstOnFee: gstOnFee ?? this.gstOnFee,
      interestRatePct: interestRatePct ?? this.interestRatePct,
      rateType: rateType ?? this.rateType,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
