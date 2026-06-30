import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/recurring_item.dart';
import '../../domain/entities/recurring_stats.dart';
import '../controllers/recurring_providers.dart';
import '../widgets/recurring_tile.dart';

/// Recurring tab — subscriptions, bills and EMIs with the true monthly outflow.
class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(recurringStatsProvider);
    final items = ref.watch(recurringItemsProvider);
    final repo = ref.read(recurringRepositoryProvider);

    return AppScaffold(
      title: 'Recurring',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recurring/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: AppSpacing.screen.copyWith(bottom: 96),
        children: [
          _OutflowHero(stats: stats),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Upcoming'),
          items.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => Text(
              "Couldn't load items.",
              style: context.text.bodyMedium,
            ),
            data: (list) => list.isEmpty
                ? EmptyState(
                    icon: Icons.event_repeat_rounded,
                    title: 'No recurring items yet',
                    message:
                        'Add a subscription, bill or EMI to see your true '
                        'monthly outflow and never miss a due date.',
                    actionLabel: 'Add item',
                    onAction: () => context.push('/recurring/add'),
                  )
                : Column(
                    children: [
                      for (final (i, item) in list.indexed) ...[
                        EntranceFade(
                          index: i,
                          child: RecurringTile(
                            item: item,
                            onEdit: () => context.push(
                              '/recurring/add',
                              extra: item,
                            ),
                            onMarkPaid: () {
                              sl<HapticService>().success();
                              repo.upsert(
                                item.copyWith(nextDueDate: item.advanceDue()),
                              );
                            },
                            onDelete: () {
                              sl<HapticService>().warning();
                              repo.delete(item.id);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _OutflowHero extends StatelessWidget {
  const _OutflowHero({required this.stats});

  final RecurringStats stats;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: c.hairline),
        const SizedBox(height: AppSpacing.lg),
        Text('PER MONTH', style: AppTypography.eyebrow(c)),
        const SizedBox(height: AppSpacing.sm),
        AnimatedCounter(
          value: stats.monthlyOutflow,
          formatter: Money.format,
          style: AppTypography.moneyHero(c, color: c.accent),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          stats.activeCount == 0
              ? 'nothing recurring yet'
              : 'across ${stats.activeCount} active '
                  '${stats.activeCount == 1 ? 'item' : 'items'}',
          style: context.text.bodyMedium,
        ),
        if (stats.byType.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final entry in stats.byType.entries)
                _TypeChip(type: entry.key, monthly: entry.value),
            ],
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, required this.monthly});

  final RecurringType type;
  final double monthly;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.brPill,
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconForType(type), size: 14, color: c.textMid),
          const SizedBox(width: AppSpacing.sm),
          Text('${type.label}  ', style: context.text.bodySmall),
          Text(
            Money.format(monthly),
            style: AppTypography.money(c, color: c.textHi).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
