import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/entities/borrowing_summary.dart';
import '../../domain/entities/repayment.dart';
import '../controllers/money_leak_providers.dart';
import '../widgets/add_repayment_sheet.dart';
import '../widgets/foreclose_sheet.dart';

const _uuid = Uuid();

/// Opens the record-payment sheet for one EMI installment, with its number and
/// due date shown as context.
void _recordInstallment(BuildContext context, String borrowingId, EmiInstallment e) {
  showAddRepaymentSheet(
    context,
    borrowingId,
    installmentNo: e.number,
    prefillAmount: e.total,
    context_: 'Installment ${e.number} · due ${e.dueDate.dayMonth}',
  );
}

class BorrowingDetailScreen extends ConsumerWidget {
  const BorrowingDetailScreen({super.key, required this.borrowingId});

  final String borrowingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(borrowingSummaryProvider(borrowingId));
    final repo = ref.read(borrowingRepositoryProvider);

    return async.when(
      loading: () => const AppScaffold(
        title: 'Details',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => AppScaffold(
        title: 'Details',
        body: Center(
          child: Text("Couldn't load this borrowing.",
              style: context.text.bodyMedium),
        ),
      ),
      data: (summary) {
        if (summary == null) {
          return const AppScaffold(
            title: 'Details',
            body: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Not found',
              message: 'This borrowing no longer exists.',
            ),
          );
        }
        final b = summary.borrowing;
        return AppScaffold(
          title: b.title,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                '/home/borrowing/$borrowingId/edit',
                extra: b,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => _onMenu(context, ref, repo, summary, v),
              itemBuilder: (_) => [
                if (summary.isEmi && !b.isClosed)
                  const PopupMenuItem(
                      value: 'foreclose', child: Text('Foreclose')),
                PopupMenuItem(
                  value: 'status',
                  child: Text(b.isClosed ? 'Mark active' : 'Mark closed'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
          floatingActionButton: _buildFab(context, summary),
          body: ListView(
            padding: AppSpacing.screen.copyWith(bottom: 96),
            children: summary.isEmi
                ? [
                    _EmiSummaryCard(summary: summary),
                    if (summary.overdueCount > 1) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _CatchUpBanner(
                        summary: summary,
                        onCatchUp: () => _catchUp(context, ref, summary),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader('Schedule'),
                    _Schedule(
                      summary: summary,
                      onRecord: (e) =>
                          _recordInstallment(context, summary.borrowing.id, e),
                    ),
                  ]
                : [
                    _LoanSummaryCard(summary: summary),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader('Ledger'),
                    _Ledger(summary: summary, onDelete: repo.deleteRepayment),
                  ],
          ),
        );
      },
    );
  }

  Widget? _buildFab(BuildContext context, BorrowingSummary summary) {
    final b = summary.borrowing;
    if (b.isClosed) return null;

    if (summary.isEmi) {
      final next = summary.nextDueInstallment;
      if (next == null) return null;
      return FloatingActionButton.extended(
        onPressed: () => _recordInstallment(context, b.id, next),
        icon: const Icon(Icons.check_rounded),
        label: const Text('Record payment'),
      );
    }

    return FloatingActionButton.extended(
      onPressed: () => showAddRepaymentSheet(context, b.id, minAmount: b.minPayment),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Record payment'),
    );
  }

  /// Log every overdue installment at once — for when the user fell behind or
  /// simply forgot to update the app.
  Future<void> _catchUp(
    BuildContext context,
    WidgetRef ref,
    BorrowingSummary summary,
  ) async {
    final overdue = summary.overdueInstallments;
    if (overdue.isEmpty) return;
    final total = summary.overdueAmount;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Record ${overdue.length} missed?'),
        content: Text(
          'This logs installments ${overdue.first.number}–${overdue.last.number} '
          '(${Money.format(total)} in total) as paid today.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record all'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    final repo = ref.read(borrowingRepositoryProvider);
    final now = DateTime.now();
    for (final e in overdue) {
      await repo.addRepayment(Repayment(
        id: _uuid.v4(),
        borrowingId: summary.borrowing.id,
        amount: e.total,
        date: now,
        installmentNo: e.number,
      ));
    }
    sl<HapticService>().success();
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    repo,
    BorrowingSummary summary,
    String action,
  ) async {
    final b = summary.borrowing;
    if (action == 'foreclose') {
      await showForecloseSheet(context, ref, summary);
      return;
    }
    if (action == 'status') {
      sl<HapticService>().select();
      await repo.upsertBorrowing(
        b.copyWith(
          status:
              b.isClosed ? BorrowingStatus.active : BorrowingStatus.closed,
        ),
      );
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete borrowing?'),
          content: const Text('This removes it and its whole ledger.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed ?? false) {
        sl<HapticService>().warning();
        await repo.deleteBorrowing(b.id);
        if (context.mounted) context.pop();
      }
    }
  }
}

/// EMI header: installments paid over the tenure, the outstanding, and progress.
class _EmiSummaryCard extends StatelessWidget {
  const _EmiSummaryCard({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(b.lenderName, style: AppTypography.eyebrow(c)),
                  if (b.isNoCostEmi) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const _NoCostBadge(),
                  ],
                ],
              ),
              Text(
                '${summary.paidInstallments}/${summary.totalInstallments}',
                style: AppTypography.money(c, color: c.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Outstanding', value: summary.outstanding),
              _Stat(
                label: 'Wasted',
                value: summary.wastedSoFar,
                color: summary.wastedSoFar > 0 ? c.cost : null,
              ),
            ],
          ),
          if (b.isNoCostEmi) ...[
            const Divider(height: AppSpacing.xl),
            BreakdownRow(
              label: 'Seller discount covered',
              amount: FinanceMath.noCostDiscount(
                price: b.principal,
                bankAnnualRatePct: b.interestRatePct,
                months: b.tenureMonths,
              ),
              color: c.positive,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          InstallmentStrip(
            total: summary.totalInstallments,
            paid: summary.paidInstallmentNumbers,
            next: summary.nextDueInstallment?.number,
            height: 8,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Scheduled total ${Money.format(summary.scheduledTotal)}',
                  style: context.text.bodySmall,
                ),
              ),
              if (summary.overdueCount > 0)
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 14, color: c.cost),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${summary.overdueCount} overdue',
                      style: context.text.bodySmall?.copyWith(color: c.cost),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when several installments are overdue: one tap to log them all, for
/// when the user fell behind or forgot to update.
class _CatchUpBanner extends StatelessWidget {
  const _CatchUpBanner({required this.summary, required this.onCatchUp});

  final BorrowingSummary summary;
  final VoidCallback onCatchUp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      color: c.surfaceHigh,
      onTap: onCatchUp,
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: c.cost),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.overdueCount} installments overdue',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${Money.format(summary.overdueAmount)} behind · tap to catch up',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }
}

/// The dated installment plan drawn as a threaded timeline: paid nodes ticked
/// in brass, the next one ringed, overdue ones flagged in ember.
class _Schedule extends StatelessWidget {
  const _Schedule({required this.summary, required this.onRecord});

  final BorrowingSummary summary;
  final void Function(EmiInstallment) onRecord;

  @override
  Widget build(BuildContext context) {
    final next = summary.nextDueInstallment;
    final schedule = summary.schedule;
    final open = !summary.borrowing.isClosed;
    return Column(
      children: [
        for (var i = 0; i < schedule.length; i++)
          _TimelineRow(
            installment: schedule[i],
            paid: summary.isInstallmentPaid(schedule[i].number),
            isNext: next != null && schedule[i].number == next.number,
            isLast: i == schedule.length - 1,
            onRecord: open && !summary.isInstallmentPaid(schedule[i].number)
                ? () => onRecord(schedule[i])
                : null,
          ),
      ],
    );
  }
}

/// One node on the schedule rail: a status dot, the connector to the next node,
/// and the installment's date and exact amount. Unpaid rows are tappable to log
/// that installment directly.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.installment,
    required this.paid,
    required this.isNext,
    required this.isLast,
    this.onRecord,
  });

  final EmiInstallment installment;
  final bool paid;
  final bool isNext;
  final bool isLast;
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final overdue = !paid && installment.dueDate.daysFromNow < 0;

    return InkWell(
      onTap: onRecord == null
          ? null
          : () {
              hapticTap();
              onRecord!();
            },
      borderRadius: AppRadius.brSm,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Rail(paid: paid, isNext: isNext, overdue: overdue, isLast: isLast),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installment ${installment.number}',
                            style: context.text.titleMedium?.copyWith(
                              color: paid ? c.textMid : c.textHi,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            paid
                                ? 'Paid'
                                : overdue
                                    ? '${installment.dueDate.dayMonthYear} · overdue'
                                    : 'Due ${installment.dueDate.dayMonthYear}',
                            style: context.text.bodySmall?.copyWith(
                              color: overdue
                                  ? c.cost
                                  : isNext
                                      ? c.accent
                                      : c.textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MoneyText(
                      installment.total,
                      color: paid ? c.textLow : c.textHi,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.paid,
    required this.isNext,
    required this.overdue,
    required this.isLast,
  });

  final bool paid;
  final bool isNext;
  final bool overdue;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: 20,
      child: Column(
        children: [
          _node(c),
          if (!isLast)
            Expanded(
              child: Container(
                width: 1.5,
                color: paid ? c.accent.withValues(alpha: 0.4) : c.hairline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _node(AppColors c) {
    if (paid) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
        child: Icon(Icons.check_rounded, size: 13, color: c.background),
      );
    }
    final color = overdue ? c.cost : (isNext ? c.accent : c.textLow);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isNext ? c.accent.withValues(alpha: 0.16) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: isNext ? 2 : 1.5),
      ),
    );
  }
}

/// Flexible-loan header: what's still owed (interest accrued), the minimum due,
/// and how much interest paying more would save.
class _LoanSummaryCard extends StatelessWidget {
  const _LoanSummaryCard({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;
    // Illustrate the saving from paying double the minimum.
    final saved =
        b.minPayment > 0 ? summary.interestSavedIfPaid(b.minPayment * 2) : 0.0;
    // Share of the interest accrued so far (the "Wasted" figure below)
    // attributable to the financed fee rather than the principal itself.
    final financedFeeInterest = b.feeFinanced
        ? FinanceMath.financedFeeInterestShare(
            principal: b.principal + b.processingFee + b.gstOnFee,
            financedAmount: b.processingFee + b.gstOnFee,
            totalInterest: summary.wastedSoFar,
          )
        : 0.0;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(b.lenderName, style: AppTypography.eyebrow(c)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Borrowed', value: b.principal),
              _Stat(label: 'Repaid', value: summary.totalRepaid),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Outstanding', value: summary.outstanding),
              _Stat(
                label: 'Wasted',
                value: summary.wastedSoFar,
                color: summary.wastedSoFar > 0 ? c.cost : null,
              ),
            ],
          ),
          if (b.minPayment > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Planned monthly payment ${Money.format(b.minPayment)}',
              style: context.text.bodySmall,
            ),
          ],
          if (saved > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Pay ${Money.format(b.minPayment * 2)}/mo to save about '
              '${Money.format(saved)} in interest.',
              style: context.text.bodySmall?.copyWith(color: c.positive),
            ),
          ],
          if (b.feeFinanced && financedFeeInterest > 0) ...[
            const Divider(height: AppSpacing.xl),
            BreakdownRow(
              label: 'Interest on the financed fee',
              amount: financedFeeInterest,
              color: c.cost,
            ),
          ],
        ],
      ),
    );
  }
}

/// Small pill marking a fixed EMI that was sold as "No Cost" — matches the
/// tag style used on the borrowing cards ([BorrowingCard]'s `_Tag`).
class _NoCostBadge extends StatelessWidget {
  const _NoCostBadge();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.positive.withValues(alpha: 0.14),
        borderRadius: AppRadius.brPill,
      ),
      child: Text(
        'NO-COST EMI',
        style: AppTypography.eyebrow(c).copyWith(color: c.positive),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          MoneyText(value, style: MoneyStyle.large, color: color),
        ],
      ),
    );
  }
}

class _Ledger extends StatelessWidget {
  const _Ledger({required this.summary, required this.onDelete});

  final BorrowingSummary summary;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repayments = [...summary.repayments]
      ..sort((a, b) => b.date.compareTo(a.date));

    if (repayments.isEmpty) {
      return Text(
        'No payments logged yet. Add one to start tracking the leak.',
        style: context.text.bodyMedium,
      );
    }

    return Column(
      children: [
        for (final r in repayments)
          _LedgerRow(repayment: r, onDelete: () => onDelete(r.id), color: c),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.repayment,
    required this.onDelete,
    required this.color,
  });

  final Repayment repayment;
  final VoidCallback onDelete;
  final AppColors color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 18, color: color.textMid),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(repayment.date.dayMonthYear,
                style: context.text.bodyMedium),
          ),
          MoneyText(repayment.amount, color: color.positive),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: color.textLow),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
