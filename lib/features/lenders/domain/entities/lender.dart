import '../../../../core/utils/finance_math.dart';

/// What kind of credit source this is.
enum LenderType {
  bnpl('BNPL / app'),
  card('Credit card'),
  nbfc('NBFC / loan');

  const LenderType(this.label);
  final String label;
}

/// A bank, card, or BNPL app in the catalog. Seeded with sensible defaults and
/// fully editable — real rates depend on the user's credit assessment.
class Lender {
  const Lender({
    required this.id,
    required this.name,
    required this.type,
    this.issuer,
    this.network,
    this.typicalRatePct = 0,
    this.rateType = RateType.reducing,
    this.feeType = FeeType.flat,
    this.feeValue = 0,
    this.isMine = false,
    this.notes,
  });

  final String id;
  final String name;
  final LenderType type;

  /// Issuing bank, e.g. "HDFC" for the Swiggy card.
  final String? issuer;

  /// Card network, e.g. "RuPay", "Visa".
  final String? network;

  /// Typical annual interest rate (%).
  final double typicalRatePct;
  final RateType rateType;
  final FeeType feeType;

  /// Flat amount or percent of principal, per [feeType].
  final double feeValue;

  /// One of the user's own cards/accounts.
  final bool isMine;
  final String? notes;

  Lender copyWith({
    String? name,
    LenderType? type,
    String? issuer,
    String? network,
    double? typicalRatePct,
    RateType? rateType,
    FeeType? feeType,
    double? feeValue,
    bool? isMine,
    String? notes,
  }) {
    return Lender(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      issuer: issuer ?? this.issuer,
      network: network ?? this.network,
      typicalRatePct: typicalRatePct ?? this.typicalRatePct,
      rateType: rateType ?? this.rateType,
      feeType: feeType ?? this.feeType,
      feeValue: feeValue ?? this.feeValue,
      isMine: isMine ?? this.isMine,
      notes: notes ?? this.notes,
    );
  }
}
