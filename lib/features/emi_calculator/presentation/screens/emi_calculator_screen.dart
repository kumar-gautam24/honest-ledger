import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/forms/app_form.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../lenders/presentation/widgets/lender_picker.dart';

/// Price → EMI. A live calculator: results update as you type. Picking a lender
/// autofills its typical rate and fee.
class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  final _fee = TextEditingController();
  RateType _rateType = RateType.reducing;

  @override
  void initState() {
    super.initState();
    for (final c in [_principal, _rate, _tenure, _fee]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_principal, _rate, _tenure, _fee]) {
      c.dispose();
    }
    super.dispose();
  }

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  Future<void> _pickLender() async {
    final lender = await showLenderPicker(context);
    if (lender == null) return;
    setState(() {
      _rateType = lender.rateType;
      if (lender.typicalRatePct > 0) _rate.text = _fmt(lender.typicalRatePct);
      if (lender.feeValue > 0) {
        final fee = FinanceMath.processingFee(
          principal: _d(_principal),
          type: lender.feeType,
          value: lender.feeValue,
          cap: lender.feeCap,
          min: lender.feeMin,
        );
        if (fee > 0) _fee.text = Money.input(fee);
      }
    });
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final principal = _d(_principal);
    final months = _i(_tenure);
    final hasResult = principal > 0 && months > 0;

    final breakdown = hasResult
        ? FinanceMath.emiBreakdown(
            principal: principal,
            annualRatePct: _d(_rate),
            months: months,
            rateType: _rateType,
            feeValue: _d(_fee),
          )
        : null;

    return AppScaffold(
      title: 'EMI Calculator',
      body: AppForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppButton(
              label: 'Autofill from a lender',
              icon: Icons.account_balance_wallet_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: _pickLender,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField.amount(
              label: 'Loan amount',
              controller: _principal,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Interest % p.a.',
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
            AppTextField.amount(
              label: 'Processing fee',
              controller: _fee,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Interest type', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<RateType>(
              segments: const [
                ButtonSegment(
                  value: RateType.reducing,
                  label: Text('Reducing'),
                ),
                ButtonSegment(value: RateType.flat, label: Text('Flat')),
              ],
              selected: {_rateType},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                sl<HapticService>().select();
                setState(() => _rateType = s.first);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            if (breakdown != null)
              _ResultCard(
                breakdown: breakdown,
                rateType: _rateType,
                onViewSchedule: _rateType == RateType.reducing
                    ? () => context.push(
                          '/tools/emi/schedule',
                          extra: ScheduleArgs(
                            principal: principal,
                            ratePct: _d(_rate),
                            months: months,
                          ),
                        )
                    : null,
              )
            else
              Text(
                'Enter a loan amount and tenure to see the EMI.',
                style: context.text.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.breakdown,
    required this.rateType,
    this.onViewSchedule,
  });

  final EmiBreakdown breakdown;
  final RateType rateType;
  final VoidCallback? onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MONTHLY EMI', style: AppTypography.eyebrow(c)),
          const SizedBox(height: AppSpacing.sm),
          MoneyText(breakdown.emi, style: MoneyStyle.hero, color: c.accent),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          BreakdownRow(
            label: 'Total interest',
            amount: breakdown.totalInterest,
            color: c.cost,
          ),
          if (breakdown.processingFee > 0)
            BreakdownRow(
              label: 'Fee + 18% GST',
              amount: breakdown.processingFee + breakdown.gstOnFee,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Effective rate',
                    style: context.text.bodyMedium,
                  ),
                ),
                Text(
                  '${Percent.format(breakdown.effectiveAnnualRatePct)} p.a.',
                  style: AppTypography.money(c, color: c.textHi),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.lg),
          BreakdownRow(
            label: 'Total payable',
            amount: breakdown.totalPayable,
            emphasise: true,
          ),
          if (onViewSchedule != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'View month-by-month schedule',
              icon: Icons.table_rows_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: onViewSchedule,
            ),
          ],
        ],
      ),
    );
  }
}

/// Args passed to the amortization schedule route.
class ScheduleArgs {
  const ScheduleArgs({
    required this.principal,
    required this.ratePct,
    required this.months,
  });
  final double principal;
  final double ratePct;
  final int months;
}
