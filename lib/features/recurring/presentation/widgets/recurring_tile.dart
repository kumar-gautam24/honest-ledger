import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/recurring_item.dart';

IconData iconForType(RecurringType type) => switch (type) {
      RecurringType.subscription => Icons.subscriptions_outlined,
      RecurringType.bill => Icons.receipt_long_outlined,
      RecurringType.emi => Icons.account_balance_outlined,
    };

/// One recurring item: icon, title, cadence, amount and a due label whose colour
/// signals how soon (or overdue) it is.
class RecurringTile extends StatelessWidget {
  const RecurringTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onMarkPaid,
    required this.onDelete,
  });

  final RecurringItem item;
  final VoidCallback onEdit;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final days = item.nextDueDate.daysFromNow;
    final dueColor = !item.isActive
        ? c.textLow
        : days < 0
            ? c.cost
            : days <= 3
                ? c.accent
                : c.textMid;

    return AppCard(
      onTap: onEdit,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: c.surfaceHigh,
              borderRadius: AppRadius.brSm,
            ),
            child: Icon(iconForType(item.type), size: 22, color: c.textMid),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.isActive
                      ? '${item.frequency.label} · ${relativeDueLabel(item.nextDueDate)}'
                      : 'Paused',
                  style: context.text.bodySmall?.copyWith(color: dueColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MoneyText(item.amount),
              if (item.frequency != Frequency.monthly)
                Text(
                  '${Money.format(item.monthlyAmount)}/mo',
                  style: context.text.bodySmall,
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (v) => switch (v) {
              'paid' => onMarkPaid(),
              'delete' => onDelete(),
              _ => null,
            },
            itemBuilder: (_) => [
              if (item.isActive)
                const PopupMenuItem(value: 'paid', child: Text('Mark paid')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
