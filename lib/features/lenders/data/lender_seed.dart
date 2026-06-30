import '../../../../core/utils/finance_math.dart';
import '../domain/entities/lender.dart';

/// Default catalog seeded on first launch. Values are typical starting points
/// (rates depend on credit assessment) and are fully editable by the user.
///
/// `isMine` marks the cards the user actually holds.
const List<Lender> kSeedLenders = [
  // ---- BNPL / app-based credit ----
  Lender(
    id: 'slice',
    name: 'slice',
    type: LenderType.bnpl,
    typicalRatePct: 36,
    feeType: FeeType.flat,
    notes: '~36% online / 42% bank transfer. Flat fee per borrow + 2.5% '
        'transfer fee + 18% GST.',
  ),
  Lender(
    id: 'mpokket',
    name: 'mPokket',
    type: LenderType.bnpl,
    typicalRatePct: 18.96,
    notes: 'Per-transaction processing fee + GST.',
  ),
  Lender(id: 'lazypay', name: 'LazyPay', type: LenderType.bnpl),
  Lender(id: 'simpl', name: 'Simpl', type: LenderType.bnpl),
  Lender(id: 'kreditbee', name: 'KreditBee', type: LenderType.nbfc),

  // ---- Generic card-EMI issuers (processing + 18% GST) ----
  Lender(
    id: 'hdfc-card-emi',
    name: 'HDFC Card EMI',
    type: LenderType.card,
    issuer: 'HDFC',
    typicalRatePct: 16,
    feeValue: 199,
    notes: 'Typical ₹199 + GST processing fee.',
  ),
  Lender(
    id: 'icici-card-emi',
    name: 'ICICI Card EMI',
    type: LenderType.card,
    issuer: 'ICICI',
    typicalRatePct: 16,
    feeValue: 99,
    notes: 'Typical ₹99 + GST processing fee.',
  ),
  Lender(
    id: 'axis-card-emi',
    name: 'Axis Card EMI',
    type: LenderType.card,
    issuer: 'Axis',
    typicalRatePct: 16,
    feeValue: 299,
    notes: 'Typical ₹299 + GST processing fee.',
  ),

  // ---- The user's own cards ----
  Lender(
    id: 'sbi-flipkart',
    name: 'SBI Flipkart',
    type: LenderType.card,
    issuer: 'SBI',
    typicalRatePct: 16,
    feeValue: 199,
    isMine: true,
  ),
  Lender(
    id: 'hdfc-swiggy',
    name: 'HDFC Swiggy',
    type: LenderType.card,
    issuer: 'HDFC',
    typicalRatePct: 16,
    feeValue: 199,
    isMine: true,
  ),
  Lender(
    id: 'hdfc-rupay',
    name: 'HDFC RuPay',
    type: LenderType.card,
    issuer: 'HDFC',
    network: 'RuPay',
    typicalRatePct: 16,
    feeValue: 199,
    isMine: true,
  ),
  Lender(
    id: 'axis-flipkart',
    name: 'Axis Flipkart',
    type: LenderType.card,
    issuer: 'Axis',
    typicalRatePct: 16,
    feeValue: 299,
    isMine: true,
  ),
  Lender(
    id: 'icici-amazon-pay',
    name: 'ICICI Amazon Pay',
    type: LenderType.card,
    issuer: 'ICICI',
    network: 'Visa',
    typicalRatePct: 16,
    feeValue: 99,
    isMine: true,
  ),
];
