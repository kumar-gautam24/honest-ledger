import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import 'emi_calculator_screen.dart';

/// Month-by-month reducing-balance breakdown: how each EMI splits into interest
/// and principal as the balance falls.
class AmortizationScreen extends StatelessWidget {
  const AmortizationScreen({super.key, required this.args});

  final ScheduleArgs args;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final schedule = FinanceMath.amortizationSchedule(
      principal: args.principal,
      annualRatePct: args.ratePct,
      months: args.months,
    );
    final emi = schedule.isEmpty ? 0.0 : schedule.first.emi;

    return AppScaffold(
      title: 'Schedule',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${args.months} months · EMI',
                    style: context.text.bodyMedium,
                  ),
                ),
                MoneyText(emi, color: c.accent),
              ],
            ),
          ),
          const _HeaderRow(),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: schedule.length,
              itemBuilder: (_, i) => _ScheduleRow(entry: schedule[i]),
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: c.hairline.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = AppTypography.eyebrow(c);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: style)),
          Expanded(child: Text('PRINCIPAL', style: style, textAlign: TextAlign.right)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text('INTEREST', style: style, textAlign: TextAlign.right)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text('BALANCE', style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.entry});

  final AmortEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${entry.month}', style: context.text.bodySmall),
          ),
          Expanded(child: _Amt(entry.principalComponent, color: c.textHi)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _Amt(entry.interest, color: c.cost)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _Amt(entry.closingBalance, color: c.textMid)),
        ],
      ),
    );
  }
}

class _Amt extends StatelessWidget {
  const _Amt(this.value, {required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      Money.format(value),
      textAlign: TextAlign.right,
      style: AppTypography.money(context.colors, color: color).copyWith(
        fontSize: 13,
      ),
    );
  }
}
