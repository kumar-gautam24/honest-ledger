import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/borrowing_summary.dart';

/// One borrowing on the home feed. A fixed EMI reads as a punch-card of
/// installments with its next due date; a flexible loan leads with the
/// interest-accrued balance still owed.
class BorrowingCard extends StatelessWidget {
  const BorrowingCard({super.key, required this.summary, this.onTap});

  final BorrowingSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(summary: summary),
          const SizedBox(height: AppSpacing.lg),
          if (summary.isEmi) _EmiBody(summary: summary) else _LoanBody(summary: summary),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.title, style: context.text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _LenderTag(name: b.lenderName),
                  const SizedBox(width: AppSpacing.sm),
                  Text(b.kind.label.toUpperCase(), style: AppTypography.eyebrow(c)),
                ],
              ),
            ],
          ),
        ),
        if (b.isClosed)
          _Tag(label: 'CLOSED', color: c.textLow)
        else if (summary.isEmi)
          _Tag(label: summary.installmentLabel!, color: c.accent)
        else if (summary.wastedSoFar > 0)
          _Tag(label: 'LEAKING', color: c.cost),
      ],
    );
  }
}

/// EMI: borrowed → total payable with the leak called out, then the installment
/// strip and the next due date.
class _EmiBody extends StatelessWidget {
  const _EmiBody({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;
    final next = summary.nextDueInstallment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BORROWED', style: AppTypography.eyebrow(c)),
                  const SizedBox(height: AppSpacing.xs),
                  MoneyText(b.principal, style: MoneyStyle.large),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Ember only for money actually wasted; a projection reads muted.
            if (summary.wastedSoFar > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: MoneyText(summary.wastedSoFar, signed: true, color: c.cost),
              )
            else if (summary.projectedExtra > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('WILL COST', style: AppTypography.eyebrow(c)),
                  const SizedBox(height: AppSpacing.xs),
                  MoneyText(summary.projectedExtra, signed: true, color: c.textMid),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        InstallmentStrip(
          total: summary.totalInstallments,
          paid: summary.paidInstallmentNumbers,
          next: next?.number,
        ),
        const SizedBox(height: AppSpacing.sm),
        Builder(
          builder: (context) {
            if (!b.isClosed && summary.overdueCount > 0) {
              return Text(
                '${summary.overdueCount} overdue · ${Money.format(summary.overdueAmount)}',
                style: context.text.bodySmall?.copyWith(color: c.cost),
              );
            }
            return Text(
              b.isClosed
                  ? 'All ${summary.totalInstallments} paid'
                  : next == null
                      ? 'Fully paid'
                      : 'Next ${Money.format(next.total)} · due ${next.dueDate.dayMonth}',
              style: context.text.bodySmall,
            );
          },
        ),
      ],
    );
  }
}

/// Loan: the outstanding balance is the headline; a thin bar shows how much of
/// it has been cleared.
class _LoanBody extends StatelessWidget {
  const _LoanBody({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OUTSTANDING', style: AppTypography.eyebrow(c)),
                const SizedBox(height: AppSpacing.xs),
                MoneyText(summary.outstanding, style: MoneyStyle.large),
              ],
            ),
            const Spacer(),
            Flexible(
              child: Text(
                'of ${Money.format(b.principal)}',
                style: context.text.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
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
              : b.minPayment > 0
                  ? 'Repaid ${Money.format(summary.totalRepaid)} · Min ${Money.format(b.minPayment)}'
                  : 'Repaid ${Money.format(summary.totalRepaid)}',
          style: context.text.bodySmall,
        ),
      ],
    );
  }
}

/// The lender/card shown as a tag on the borrowing — distinct from the
/// purchase title.
class _LenderTag extends StatelessWidget {
  const _LenderTag({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.brPill,
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_rounded, size: 12, color: c.textLow),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            name,
            style: context.text.bodySmall?.copyWith(color: c.textMid),
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
