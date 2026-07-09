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
    this.feeCap,
    this.feeMin,
    this.foreclosurePct,
    this.foreclosureMin,
    this.foreclosureFreeWindowDays,
    this.foreclosureGst = true,
    this.foreclosureExtraInterestDays = 0,
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

  /// Upper cap on a percent fee (e.g. ICICI 2.99% but max ₹299). Null = no cap.
  final double? feeCap;

  /// Lower floor on a percent fee (e.g. SBI 2% but min ₹199). Null = no floor.
  final double? feeMin;

  /// Foreclosure fee as a percent of the principal still outstanding. Cards
  /// charge ~3%; slice charges nothing (RBI Pre-payment Charges Directions,
  /// 2025). Null = unknown, so the app asks rather than guesses.
  final double? foreclosurePct;

  /// Floor on the foreclosure fee — Axis takes 3% *or ₹300, whichever is more*.
  final double? foreclosureMin;

  /// Days after booking within which foreclosure is free (HDFC 30, Axis 7).
  final int? foreclosureFreeWindowDays;

  /// Whether GST rides on the foreclosure fee. True for card EMIs.
  final bool foreclosureGst;

  /// Extra days of interest charged on top when foreclosing. slice adds 1 "due
  /// to settlement delay" — a cost visible only in a KFS footnote.
  final int foreclosureExtraInterestDays;

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
    double? feeCap,
    double? feeMin,
    double? foreclosurePct,
    double? foreclosureMin,
    int? foreclosureFreeWindowDays,
    bool? foreclosureGst,
    int? foreclosureExtraInterestDays,
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
      feeCap: feeCap ?? this.feeCap,
      feeMin: feeMin ?? this.feeMin,
      foreclosurePct: foreclosurePct ?? this.foreclosurePct,
      foreclosureMin: foreclosureMin ?? this.foreclosureMin,
      foreclosureFreeWindowDays:
          foreclosureFreeWindowDays ?? this.foreclosureFreeWindowDays,
      foreclosureGst: foreclosureGst ?? this.foreclosureGst,
      foreclosureExtraInterestDays:
          foreclosureExtraInterestDays ?? this.foreclosureExtraInterestDays,
      isMine: isMine ?? this.isMine,
      notes: notes ?? this.notes,
    );
  }
}
