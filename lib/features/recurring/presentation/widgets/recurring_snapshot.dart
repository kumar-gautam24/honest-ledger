import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/recurring_item.dart';
import '../controllers/recurring_providers.dart';

/// Compact "recurring this month" card shown on the Home overview. Hidden when
/// there is nothing recurring. Tapping jumps to the Recurring tab.
class RecurringSnapshot extends ConsumerWidget {
  const RecurringSnapshot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final stats = ref.watch(recurringStatsProvider);
    if (stats.activeCount == 0) return const SizedBox.shrink();

    final items = ref.watch(recurringItemsProvider);
    final next = items.maybeWhen(
      data: (list) {
        final active = list.where((i) => i.isActive).toList()
          ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
        return active.isEmpty ? null : active.first;
      },
      orElse: () => null,
    );

    return AppCard(
      onTap: () => context.go('/recurring'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RECURRING / MONTH', style: AppTypography.eyebrow(c)),
                const SizedBox(height: AppSpacing.sm),
                MoneyText(stats.monthlyOutflow, style: MoneyStyle.large),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${stats.activeCount} active '
                  '${stats.activeCount == 1 ? 'item' : 'items'}',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          if (next != null) _NextDue(item: next),
        ],
      ),
    );
  }
}

class _NextDue extends StatelessWidget {
  const _NextDue({required this.item});

  final RecurringItem item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final overdue = item.nextDueDate.daysFromNow < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('NEXT DUE', style: AppTypography.eyebrow(c)),
        const SizedBox(height: AppSpacing.sm),
        Text(item.title, style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          relativeDueLabel(item.nextDueDate),
          style: context.text.bodySmall?.copyWith(
            color: overdue ? c.cost : c.accent,
          ),
        ),
      ],
    );
  }
}
