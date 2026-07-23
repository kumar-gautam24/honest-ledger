import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../recurring/presentation/controllers/recurring_providers.dart';
import '../../../settings/presentation/controllers/income_controller.dart';
import '../../domain/entities/month_plan.dart';
import '../../domain/entities/monthly_obligation_stats.dart';
import '../../domain/entities/outflow_projection.dart';
import '../home_providers.dart';
import '../obligation_view.dart';

/// This Month — the calendar month as a statement: what's due, what's been
/// paid, what remains — followed by the coming year's outflow timeline.
class MonthPlanScreen extends ConsumerWidget {
  const MonthPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(monthPlanProvider);
    final projection = ref.watch(outflowProjectionProvider);

    return AppScaffold(
      title: 'This Month',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          EntranceFade(index: 0, child: _MonthStatement(plan: plan)),
          const SizedBox(height: AppSpacing.xxl),
          const EntranceFade(
            index: 1,
            child: SectionHeader("This month's dues"),
          ),
          if (plan.dues.isEmpty)
            const EntranceFade(
              index: 2,
              child: EmptyState(
                icon: Icons.event_available_rounded,
                title: 'Nothing due this month',
                message: 'EMIs, loan payments and recurring dues that land '
                    'this month will show up here.',
              ),
            )
          else
            for (final (i, due) in plan.dues.indexed)
              EntranceFade(index: 2 + i, child: _DueRow(due: due)),
          if (projection.maxMonthTotal > 0) ...[
            const SizedBox(height: AppSpacing.xxl),
            EntranceFade(
              index: 3 + plan.dues.length,
              child: const SectionHeader('Next 12 months'),
            ),
            EntranceFade(
              index: 4 + plan.dues.length,
              child: _Timeline(projection: projection),
            ),
          ],
        ],
      ),
    );
  }
}

/// The statement header: month eyebrow, the due-this-month hero with the brass
/// fill-rule, paid/remaining lines, a settle-progress bar, and the steady-state
/// per-month figure with its kind breakdown.
class _MonthStatement extends ConsumerWidget {
  const _MonthStatement({required this.plan});

  final MonthPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final settled = plan.totalDue > 0 && plan.remaining <= 0;
    final monthly = ref.watch(monthlyObligationStatsProvider);
    final income = ref.watch(incomeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: c.hairline),
        const SizedBox(height: AppSpacing.lg),
        Text(
          plan.month.monthYear.toUpperCase(),
          style: AppTypography.eyebrow(c),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('DUE THIS MONTH', style: AppTypography.eyebrow(c)),
        const SizedBox(height: AppSpacing.sm),
        IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCounter(
                value: plan.totalDue,
                formatter: Money.format,
                style: AppTypography.moneyHero(c),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: AppRadius.brPill,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        BreakdownRow(
          label: 'Paid so far',
          amount: plan.totalPaid,
          color: c.positive,
        ),
        BreakdownRow(
          label: 'Remaining',
          amount: plan.remaining,
          emphasise: true,
          color: settled ? c.positive : null,
        ),
        if (plan.carriedOver > 0)
          BreakdownRow(
            label: 'Overdue from earlier',
            amount: plan.carriedOver,
            color: c.cost,
          ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: AppRadius.brPill,
          child: SizedBox(
            height: 3,
            child: Stack(
              children: [
                Container(color: c.surfaceHigh),
                FractionallySizedBox(
                  widthFactor: plan.progress,
                  child: Container(color: c.accent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(height: 1, color: c.hairline),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('PER MONTH', style: AppTypography.eyebrow(c)),
                  const Spacer(),
                  MoneyText(monthly.total, color: c.accent),
                ],
              ),
              if (monthly.byCategory.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(_breakdownLine(monthly), style: context.text.bodySmall),
              ],
              if (income != null && income > 0 && monthly.total > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${Percent.format(monthly.total / income * 100, decimals: 0)} '
                  'of your income',
                  style: context.text.bodySmall,
                ),
              ],
              if (monthly.unplannedLoanCount > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  monthly.unplannedLoanCount == 1
                      ? '1 loan has no planned payment'
                      : '${monthly.unplannedLoanCount} loans have no '
                          'planned payment',
                  style: context.text.bodySmall?.copyWith(color: c.cost),
                ),
              ],
            ],
          ),
        ),
        Container(height: 1, color: c.hairline),
      ],
    );
  }

  /// `EMIs ₹12.4k · Loans ₹5k · Subs ₹599` — non-zero kinds only.
  String _breakdownLine(MonthlyObligationStats monthly) {
    final parts = <String>[
      for (final f in ObligationFilter.values)
        if (f != ObligationFilter.all)
          for (final MapEntry(:key, :value) in monthly.byCategory.entries)
            if (key.name == f.name && value > 0)
              '${f.label} ${Money.compact(value)}',
    ];
    return parts.join(' · ');
  }
}

/// One statement line of the month: date column, what it is, and how much —
/// with paid / overdue / no-plan states.
class _DueRow extends ConsumerWidget {
  const _DueRow({required this.due});

  final MonthDue due;

  String get _kindLabel => switch (due.source) {
        MonthDueSource.emiInstallment =>
          'EMI · ${due.installmentNo}/${due.installmentCount}',
        MonthDueSource.flexiblePlan => 'LOAN',
        MonthDueSource.recurring => due.category.name.toUpperCase(),
        MonthDueSource.cardBill => 'CARD BILL',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final now = DateTime.now();
    final paid = due.isPaid;
    final overdue = due.isOverdue(now);
    final dateColor = paid
        ? c.textLow
        : overdue
            ? c.cost
            : c.textMid;

    return InkWell(
      onTap: () {
        sl<HapticService>().select();
        switch (due.source) {
          case MonthDueSource.emiInstallment || MonthDueSource.flexiblePlan:
            context.push('/home/borrowing/${due.sourceId}');
          case MonthDueSource.recurring:
            final items =
                ref.read(recurringItemsProvider).asData?.value ?? const [];
            for (final item in items) {
              if (item.id == due.sourceId) {
                context.push('/home/add-recurring', extra: item);
                break;
              }
            }
          case MonthDueSource.cardBill:
            context.push('/cards/${due.sourceId}');
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    due.dueDate?.dayMonth.toUpperCase() ?? 'ANY\nDAY',
                    style: AppTypography.eyebrow(c).copyWith(color: dateColor),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        due.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyLarge?.copyWith(
                          color: paid ? c.textMid : c.textHi,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _kindLabel,
                        style: AppTypography.eyebrow(c)
                            .copyWith(color: c.textLow),
                      ),
                      if (due.noPlan) ...[
                        const SizedBox(height: 2),
                        Text(
                          'No planned payment set',
                          style: context.text.bodySmall
                              ?.copyWith(color: c.cost),
                        ),
                      ] else if ((due.source == MonthDueSource.flexiblePlan ||
                              due.source == MonthDueSource.cardBill) &&
                          due.amountPaid > 0 &&
                          !paid) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${Money.format(due.amountPaid)} of '
                          '${Money.format(due.amountDue)} paid',
                          style: context.text.bodySmall,
                        ),
                      ],
                      if (due.foldedAmount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'incl. ${Money.format(due.foldedAmount)} EMIs & subs',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                if (due.noPlan)
                  Icon(Icons.error_outline_rounded, size: 18, color: c.cost)
                else
                  Row(
                    children: [
                      if (paid) ...[
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: c.positive,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      MoneyText(
                        due.amountDue,
                        color: paid ? c.textLow : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(height: 1, color: c.hairline),
        ],
      ),
    );
  }
}

/// The coming year as statement rows: month, a relative outflow bar, the total
/// — and a callout under each month where money frees up.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.projection});

  final OutflowProjection projection;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (final (i, m) in projection.months.indexed) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    i == 0 || m.month.month == 1
                        ? '${m.month.monthShort} ${m.month.year % 100}'
                              .toUpperCase()
                        : m.month.monthShort.toUpperCase(),
                    style: AppTypography.eyebrow(c).copyWith(
                      color: i == 0 ? c.textHi : c.textMid,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.brPill,
                    child: SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(color: c.surfaceHigh),
                          FractionallySizedBox(
                            widthFactor: projection.maxMonthTotal <= 0
                                ? 0
                                : (m.total / projection.maxMonthTotal)
                                    .clamp(0.0, 1.0),
                            child: Container(
                              color: c.accent.withValues(
                                alpha: i == 0 ? 1.0 : 0.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                MoneyText(
                  m.total,
                  compact: true,
                  color: i == 0 ? null : c.textMid,
                ),
              ],
            ),
          ),
          for (final e in projection.events)
            if (e.freedFrom.isSameMonth(m.month))
              Padding(
                padding: const EdgeInsets.only(
                  left: 56 + AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_down_rounded,
                      size: 16,
                      color: c.positive,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${Money.format(e.monthlyFreed)}/mo free — '
                        '${e.title} ends',
                        style: context.text.bodySmall
                            ?.copyWith(color: c.positive),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ],
    );
  }
}
