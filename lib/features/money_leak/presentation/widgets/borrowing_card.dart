import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/borrowing_summary.dart';

/// One borrowing on the dashboard: `principal → scheduled` with the leak called
/// out, plus repayment progress.
class BorrowingCard extends StatelessWidget {
  const BorrowingCard({super.key, required this.summary, this.onTap});

  final BorrowingSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title, style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(b.lenderName, style: context.text.bodySmall),
                  ],
                ),
              ),
              if (b.isClosed)
                _Tag(label: 'CLOSED', color: c.textLow)
              else if (summary.projectedExtra > 0)
                _Tag(label: 'LEAKING', color: c.cost),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              MoneyText(b.principal, style: MoneyStyle.inline),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 18,
                  color: c.textLow,
                ),
              ),
              MoneyText(
                summary.scheduledTotal,
                style: MoneyStyle.inline,
                color: c.textHi,
              ),
              const Spacer(),
              if (summary.projectedExtra > 0)
                MoneyText(
                  summary.projectedExtra,
                  signed: true,
                  color: c.cost,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.brPill,
            child: LinearProgressIndicator(
              value: summary.progress.toDouble(),
              minHeight: 4,
              backgroundColor: c.surfaceHigh,
              valueColor: AlwaysStoppedAnimation(c.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            b.isClosed
                ? 'Repaid ${Money.format(summary.totalRepaid)}'
                : 'Repaid ${Money.format(summary.totalRepaid)} · '
                    'Outstanding ${Money.format(summary.outstanding)}',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.brPill,
      ),
      child: Text(
        label,
        style: AppTypography.eyebrow(context.colors).copyWith(color: color),
      ),
    );
  }
}
