import '../../../../core/utils/finance_math.dart';
import '../domain/entities/lender.dart';

/// Bump when the seed values below change so the app refreshes them on upgrade.
const int kLenderSeedVersion = 4;

/// Ids of the built-in catalog entries. These ship with the app (and live in the
/// server's global catalog), so they are NOT synced to the per-user `/v1/lenders`
/// store — only lenders the user adds are.
final Set<String> kSeedLenderIds = {for (final l in kSeedLenders) l.id};

/// Default catalog seeded on first launch. Values are typical starting points
/// sourced from each provider's public EMI/loan terms (2026); real rates depend
/// on your credit assessment, so everything here is editable. Entries whose
/// notes say "verified" were checked against an official source (T&C / KFS);
/// entries marked "indicative" are estimates and may be off for your card.
///
/// Card EMI processing fees are usually a **percent of the purchase** (≈1–2%),
/// not a small flat amount — modelled with [FeeType.percent].
///
/// `isMine` marks the cards the user actually holds.
const List<Lender> kSeedLenders = [
  // ---- BNPL / app-based credit ----
  Lender(
    id: 'slice',
    name: 'slice',
    type: LenderType.bnpl,
    typicalRatePct: 36,
    feeType: FeeType.percent,
    feeValue: 2.5,
    notes: 'slice borrow ~18% p.a. (indicative); slice card ~36% online / '
        '42% bank transfer. 2.5% transfer fee (min ₹25) + 18% GST. '
        'Slice SFB personal loan (real KFS, Jan 2026): 31.15% p.a., fee '
        '~4.5% financed INTO the loan, APR 39.73%. Use the "Fee added to '
        'the loan" toggle.',
  ),
  Lender(
    id: 'mpokket',
    name: 'mPokket',
    type: LenderType.bnpl,
    typicalRatePct: 30,
    feeType: FeeType.percent,
    feeValue: 3.75,
    notes: '1.58–3%/month (AIR up to 36%, APR up to ~58%, indicative). '
        'Processing ~3.75% + GST.',
  ),
  Lender(
    id: 'lazypay',
    name: 'LazyPay',
    type: LenderType.bnpl,
    typicalRatePct: 24,
    notes: '18–32% p.a. depending on profile (indicative).',
  ),
  Lender(
    id: 'simpl',
    name: 'Simpl',
    type: LenderType.bnpl,
    notes: 'Interest-free if paid on time; late fees apply.',
  ),
  Lender(
    id: 'kreditbee',
    name: 'KreditBee',
    type: LenderType.nbfc,
    typicalRatePct: 24,
    feeType: FeeType.percent,
    feeValue: 5,
    notes: '12–28.5% p.a. (indicative). Processing up to ~5.1% + GST.',
  ),

  // ---- Generic card-EMI issuers (processing ≈1–2% + 18% GST) ----
  Lender(
    id: 'hdfc-card-emi',
    name: 'HDFC Card EMI',
    type: LenderType.card,
    issuer: 'HDFC',
    typicalRatePct: 16.05,
    feeType: FeeType.percent,
    feeValue: 2,
    feeMin: 149,
    feeCap: 849,
    notes: 'SmartEMI: POS ~16.05% p.a., post-purchase ~18% p.a. '
        'Promotional rates as low as 0.99%/month on select merchants '
        '(indicative). Processing up to 2% (min ₹149, max ₹849) + 18% GST.',
  ),
  Lender(
    id: 'icici-card-emi',
    name: 'ICICI Card EMI',
    type: LenderType.card,
    issuer: 'ICICI',
    typicalRatePct: 15.99,
    feeType: FeeType.percent,
    feeValue: 2.99,
    feeCap: 299,
    notes: 'Instant EMI 15.99% p.a.; 2.99% fee (max ₹299) + 18% GST. '
        'EMI-on-call: up to 2% of the amount. Verified from ICICI Instant '
        'EMI T&C, Jul 2026.',
  ),
  Lender(
    id: 'sbi-card-emi',
    name: 'SBI Card EMI',
    type: LenderType.card,
    issuer: 'SBI',
    typicalRatePct: 15,
    feeType: FeeType.percent,
    feeValue: 2,
    feeMin: 199,
    feeCap: 1000,
    notes: 'Merchant EMI ~15%. Post-purchase Flexipay is 22% p.a.; fee 2% '
        '(min ₹199, max ₹1,000) + GST. Verified Jun 2026.',
  ),
  Lender(
    id: 'axis-card-emi',
    name: 'Axis Card EMI',
    type: LenderType.card,
    issuer: 'Axis',
    typicalRatePct: 16,
    feeValue: 150,
    notes: 'Merchant EMI ~14% / post-purchase ~18% p.a. (indicative). '
        'Processing ₹150 (+18% GST); some products up to 2%.',
  ),
  Lender(
    id: 'kotak-card-emi',
    name: 'Kotak Card EMI',
    type: LenderType.card,
    issuer: 'Kotak',
    typicalRatePct: 16,
    feeType: FeeType.flat,
    feeValue: 199,
    notes: 'Kotak Card EMI (indicative): ~16% p.a.; flat ₹199 processing '
        'fee + 18% GST.',
  ),
  Lender(
    id: 'amex-card-emi',
    name: 'Amex Card EMI',
    type: LenderType.card,
    issuer: 'Amex',
    typicalRatePct: 14.99,
    feeType: FeeType.flat,
    feeValue: 250,
    notes: 'Amex Card EMI (indicative): ~14.99% p.a.; flat ₹250 processing '
        'fee + 18% GST.',
  ),

  // ---- The user's own cards (map to the issuer's EMI terms) ----
  Lender(
    id: 'sbi-flipkart',
    name: 'SBI Flipkart',
    type: LenderType.card,
    issuer: 'SBI',
    typicalRatePct: 16,
    feeType: FeeType.percent,
    feeValue: 1,
    feeCap: 2000,
    isMine: true,
    notes: 'SBI Card Flexipay: 9.75–24% p.a. (indicative); 1% fee '
        '(max ₹2000) + 18% GST; nil for 24/36 months.',
  ),
  Lender(
    id: 'hdfc-swiggy',
    name: 'HDFC Swiggy',
    type: LenderType.card,
    issuer: 'HDFC',
    typicalRatePct: 16,
    feeType: FeeType.percent,
    feeValue: 2,
    feeMin: 149,
    feeCap: 849,
    isMine: true,
    notes: 'HDFC SmartEMI (indicative): up to 2% fee (min ₹149, max ₹849) '
        '+ 18% GST.',
  ),
  Lender(
    id: 'hdfc-rupay',
    name: 'HDFC RuPay',
    type: LenderType.card,
    issuer: 'HDFC',
    network: 'RuPay',
    typicalRatePct: 16,
    feeType: FeeType.percent,
    feeValue: 2,
    feeMin: 149,
    feeCap: 849,
    isMine: true,
    notes: 'HDFC SmartEMI (indicative): up to 2% fee (min ₹149, max ₹849) '
        '+ 18% GST.',
  ),
  Lender(
    id: 'axis-flipkart',
    name: 'Axis Flipkart',
    type: LenderType.card,
    issuer: 'Axis',
    typicalRatePct: 16,
    feeValue: 150,
    isMine: true,
    notes: 'Axis EMI terms: ~14–18% p.a. (indicative); ₹150 fee '
        '(+18% GST); some products up to 2%.',
  ),
  Lender(
    id: 'icici-amazon-pay',
    name: 'ICICI Amazon Pay',
    type: LenderType.card,
    issuer: 'ICICI',
    network: 'Visa',
    typicalRatePct: 15.99,
    feeType: FeeType.percent,
    feeValue: 2.99,
    feeCap: 299,
    isMine: true,
    notes: 'ICICI Instant EMI 15.99% p.a.; 2.99% fee (max ₹299) + 18% GST. '
        'Verified from ICICI Instant EMI T&C, Jul 2026.',
  ),
];
