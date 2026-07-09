import 'package:flutter/material.dart';

import '../../../../core/forms/app_form.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../lenders/domain/entities/lender.dart';
import '../../../lenders/presentation/widgets/lender_picker.dart';

/// Reveals the real cost of a "No Cost EMI" offer: GST on the bank's interest
/// and the processing fee still leak through.
class NoCostEmiScreen extends StatefulWidget {
  const NoCostEmiScreen({super.key});

  @override
  State<NoCostEmiScreen> createState() => _NoCostEmiScreenState();
}

class _NoCostEmiScreenState extends State<NoCostEmiScreen> {
  final _price = TextEditingController();
  final _tenure = TextEditingController();
  final _rate = TextEditingController();
  final _fee = TextEditingController();
  final _discount = TextEditingController();
  Lender? _lender;

  @override
  void initState() {
    super.initState();
    for (final c in [_price, _tenure, _rate, _fee, _discount]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_price, _tenure, _rate, _fee, _discount]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  /// Picking a lender autofills the bank rate and processing fee (computed
  /// off the price already entered, respecting the lender's fee cap); both
  /// stay editable, and manual entry keeps working when no lender is picked.
  Future<void> _pickLender() async {
    final lender = await showLenderPicker(context);
    if (lender == null) return;
    setState(() {
      _lender = lender;
      if (_rate.text.isEmpty && lender.typicalRatePct > 0) {
        _rate.text = _n(lender.typicalRatePct);
      }
      if (_fee.text.isEmpty && lender.feeValue > 0) {
        final fee = FinanceMath.processingFee(
          principal: _d(_price),
          type: lender.feeType,
          value: lender.feeValue,
          cap: lender.feeCap,
        );
        if (fee > 0) _fee.text = Money.input(fee);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final price = _d(_price);
    final months = _i(_tenure);
    final hasResult = price > 0 && months > 0;

    final result = hasResult
        ? FinanceMath.noCostEmi(
            price: price,
            months: months,
            bankAnnualRatePct: _d(_rate),
            feeValue: _d(_fee),
            forfeitedDiscount: _d(_discount),
          )
        : null;

    return AppScaffold(
      title: 'No-Cost EMI',
      body: AppForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter what the bank would normally charge — the analyzer shows "
              "what the '0%' offer really costs you.",
              style: context.text.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.amount(
              label: 'Product price',
              controller: _price,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('LENDER / CARD (OPTIONAL)', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            _LenderField(lender: _lender, onTap: _pickLender),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: "Bank's interest % p.a.",
                    controller: _rate,
                    hint: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Tenure (months)',
                    controller: _tenure,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(label: 'Processing fee', controller: _fee),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(
              label: 'Upfront discount you give up (optional)',
              controller: _discount,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (result != null)
              _ResultCard(result: result)
            else
              Text(
                'Enter a price and tenure to reveal the true cost.',
                style: context.text.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

/// Tappable lender/card picker — mirrors `_LenderField` on the add/edit
/// borrowing screen but is explicitly optional (this is a scratch analyzer,
/// not a saved borrowing).
class _LenderField extends StatelessWidget {
  const _LenderField({required this.lender, required this.onTap});

  final Lender? lender;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: c.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              lender?.name ?? 'Choose lender or card',
              style: lender == null
                  ? context.text.bodyMedium
                  : context.text.titleMedium,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }
}

/// The one-line comparison a shopper actually faces at checkout: does the
/// no-cost EMI's true cost beat simply paying upfront and taking the same
/// discount in cash? Null when no discount was entered — there's nothing to
/// compare against.
String? noCostVerdict({
  required double trueCost,
  required double price,
  required double forfeitedDiscount,
}) {
  if (forfeitedDiscount <= 0) return null;
  final upfrontCost = price - forfeitedDiscount;
  final diff = trueCost - upfrontCost;
  if (diff.abs() <= 1) return 'Either way costs about the same.';
  if (diff > 0) return 'Paying upfront is cheaper by ${Money.format(diff)}.';
  return 'No-cost EMI wins by ${Money.format(-diff)}.';
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final NoCostEmiBreakdown result;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final free = result.isActuallyFree;
    final accentColor = free ? c.positive : c.cost;
    final verdict = noCostVerdict(
      trueCost: result.trueCost,
      price: result.price,
      forfeitedDiscount: result.forfeitedDiscount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verdict banner.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.brCard,
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                free ? 'GENUINELY FREE' : 'NOT ACTUALLY FREE',
                style: AppTypography.eyebrow(c).copyWith(color: accentColor),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (free)
                Text(
                  'No interest and no fees — this one really is 0%.',
                  style: context.text.bodyMedium,
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    MoneyText(
                      result.totalExtra,
                      style: MoneyStyle.large,
                      color: accentColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('extra over the price', style: context.text.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BreakdownRow(
                label: 'Shows on statement (price ÷ months)',
                amount: result.monthlyInstallment,
              ),
              const Divider(height: AppSpacing.lg),
              Text('WHAT LEAKS THROUGH', style: AppTypography.eyebrow(c)),
              const SizedBox(height: AppSpacing.sm),
              if (result.merchantDiscount > 0)
                BreakdownRow(
                  label: 'Seller discount covers',
                  amount: result.merchantDiscount,
                  color: c.positive,
                ),
              BreakdownRow(
                label: '18% GST on bank interest',
                amount: result.gstOnInterest,
                color: c.cost,
              ),
              if (result.processingFee > 0)
                BreakdownRow(
                  label: 'Processing fee + GST',
                  amount: result.processingFee + result.gstOnFee,
                  color: c.cost,
                ),
              if (result.forfeitedDiscount > 0)
                BreakdownRow(
                  label: 'Forfeited upfront discount',
                  amount: result.forfeitedDiscount,
                  color: c.cost,
                ),
              const Divider(height: AppSpacing.lg),
              BreakdownRow(
                label: 'True cost',
                amount: result.trueCost,
                emphasise: true,
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Effective rate '
                  '${Percent.format(result.effectiveAnnualRatePct)} p.a. '
                  'vs the advertised 0%.',
                  style: context.text.bodySmall,
                ),
              ),
              if (verdict != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    verdict,
                    style: context.text.bodySmall?.copyWith(color: c.textMid),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
