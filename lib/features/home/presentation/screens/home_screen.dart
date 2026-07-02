import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../../money_leak/presentation/widgets/borrowing_card.dart';
import '../../../recurring/presentation/controllers/recurring_providers.dart';
import '../../../recurring/presentation/widgets/recurring_tile.dart';
import '../../../settings/presentation/controllers/income_controller.dart';
import '../controllers/catch_up_controller.dart';
import '../home_providers.dart';
import '../obligation_view.dart';
import '../widgets/add_obligation_sheet.dart';
import '../widgets/catch_up_card.dart';

/// Home — the single place for every obligation: EMIs, loans, subscriptions and
/// bills, sorted by urgency with a filter to slice by kind.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ObligationFilter _filter = ObligationFilter.all;

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final loading = ref.watch(homeFeedLoadingProvider);
    final visible =
        feed.where((o) => _filter.accepts(o.category)).toList(growable: false);

    return AppScaffold(
      title: 'Home',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddObligationSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: AppSpacing.screen.copyWith(bottom: 96),
        children: [
          const _HomeHero(),
          const _CatchUpSection(),
          const SizedBox(height: AppSpacing.xl),
          _FilterBar(
            selected: _filter,
            onSelected: (f) {
              sl<HapticService>().select();
              setState(() => _filter = f);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (loading && feed.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (visible.isEmpty)
            _EmptyForFilter(filter: _filter, hasAny: feed.isNotEmpty)
          else
            for (final (i, o) in visible.indexed) ...[
              EntranceFade(index: i, child: _ObligationRow(obligation: o)),
              const SizedBox(height: AppSpacing.md),
            ],
        ],
      ),
    );
  }
}

/// Renders each obligation with its own widget while keeping one unified list.
class _ObligationRow extends ConsumerWidget {
  const _ObligationRow({required this.obligation});

  final ObligationView obligation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (obligation) {
      case BorrowingObligation(:final summary):
        return BorrowingCard(
          summary: summary,
          onTap: () =>
              context.push('/home/borrowing/${summary.borrowing.id}'),
        );
      case RecurringObligation(:final item):
        final repo = ref.read(recurringRepositoryProvider);
        return RecurringTile(
          item: item,
          onEdit: () => context.push('/home/add-recurring', extra: item),
          onMarkPaid: () {
            sl<HapticService>().success();
            repo.upsert(item.copyWith(nextDueDate: item.advanceDue()));
          },
          onDelete: () {
            sl<HapticService>().warning();
            repo.delete(item.id);
          },
        );
    }
  }
}

/// Shows the "while you were away" card only when pre-month arrears exist.
class _CatchUpSection extends ConsumerWidget {
  const _CatchUpSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catchUp = ref.watch(catchUpProvider);
    if (catchUp.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: CatchUpCard(catchUp: catchUp),
    );
  }
}

/// The statement header. The operational figure leads: what's still to pay
/// this month (tap → the month statement). Lifetime waste — the app's
/// signature — is the second line (tap → the Leak).
class _HomeHero extends ConsumerWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final lifetime = ref.watch(lifetimeStatsProvider);
    final plan = ref.watch(monthPlanProvider);
    final income = ref.watch(incomeControllerProvider);
    final now = DateTime.now();
    final hasOverdue = plan.dues.any((d) => d.isOverdue(now));
    final settled = plan.remaining <= 0;
    final leftAfter = income == null ? null : income - plan.totalDue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: c.hairline),
        InkWell(
          onTap: () {
            sl<HapticService>().select();
            context.push('/home/month');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'REMAINING THIS MONTH',
                      style: AppTypography.eyebrow(c),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: c.textLow,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedCounter(
                        value: plan.remaining,
                        formatter: Money.format,
                        style: AppTypography.moneyHero(
                          c,
                          color: hasOverdue
                              ? c.cost
                              : settled
                                  ? c.positive
                                  : c.textHi,
                        ),
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  plan.totalDue > 0
                      ? 'due ${Money.format(plan.totalDue)} · '
                          'paid ${Money.format(plan.totalPaid)}'
                      : 'nothing due this month — for now',
                  style: context.text.bodyMedium,
                ),
                if (leftAfter != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    leftAfter < 0
                        ? '${Money.format(-leftAfter)} over your income'
                        : '${Money.format(leftAfter)} left after obligations',
                    style: context.text.bodySmall?.copyWith(
                      color: leftAfter < 0 ? c.cost : c.textMid,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Container(height: 1, color: c.hairline),
        InkWell(
          onTap: () {
            sl<HapticService>().select();
            context.push('/home/waste');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Text('LIFETIME WASTED', style: AppTypography.eyebrow(c)),
                const Spacer(),
                AnimatedCounter(
                  value: lifetime.totalWasted,
                  formatter: Money.format,
                  style: AppTypography.money(
                    c,
                    color: lifetime.totalWasted > 0 ? c.cost : c.textMid,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right_rounded, size: 18, color: c.textLow),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final ObligationFilter selected;
  final ValueChanged<ObligationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in ObligationFilter.values) ...[
            _FilterChip(
              label: f.label,
              selected: f == selected,
              onTap: () => onSelected(f),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? c.accent.withValues(alpha: 0.16) : c.surface,
          borderRadius: AppRadius.brPill,
          border: Border.all(color: selected ? c.accent : c.hairline),
        ),
        child: Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: selected ? c.accent : c.textMid,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _EmptyForFilter extends StatelessWidget {
  const _EmptyForFilter({required this.filter, required this.hasAny});

  final ObligationFilter filter;
  final bool hasAny;

  @override
  Widget build(BuildContext context) {
    if (hasAny) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Center(
          child: Text(
            'Nothing under ${filter.label}.',
            style: context.text.bodyMedium,
          ),
        ),
      );
    }
    return EmptyState(
      icon: Icons.receipt_long_rounded,
      title: 'Nothing tracked yet',
      message: 'Add an EMI, a loan, a subscription or a bill — and see what '
          "it's really costing you every month.",
      actionLabel: 'Add',
      onAction: () => showAddObligationSheet(context),
    );
  }
}
