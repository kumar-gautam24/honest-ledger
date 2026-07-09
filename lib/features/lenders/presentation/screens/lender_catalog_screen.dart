import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/lender.dart';
import '../lender_providers.dart';

/// Manage the catalog: your cards and every bank/BNPL app, with editable rates
/// and fees.
class LenderCatalogScreen extends ConsumerWidget {
  const LenderCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lenders = ref.watch(allLendersProvider);

    return AppScaffold(
      title: 'Cards & lenders',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/settings/lenders/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: lenders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text("Couldn't load the catalog.",
              style: context.text.bodyMedium),
        ),
        data: (list) {
          final mine = list.where((l) => l.isMine).toList();
          final others = list.where((l) => !l.isMine).toList();
          return ListView(
            padding: AppSpacing.screen.copyWith(bottom: 96),
            children: [
              if (mine.isNotEmpty) ...[
                const SectionHeader('My cards'),
                ...mine.map((l) => _LenderRow(lender: l)),
                const SizedBox(height: AppSpacing.xl),
              ],
              const SectionHeader('Catalog'),
              ...others.map((l) => _LenderRow(lender: l)),
            ],
          );
        },
      ),
    );
  }
}

class _LenderRow extends ConsumerWidget {
  const _LenderRow({required this.lender});

  final Lender lender;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final feeBounds = [
      if (lender.feeMin != null) 'min ${Money.format(lender.feeMin!)}',
      if (lender.feeCap != null) 'max ${Money.format(lender.feeCap!)}',
    ].join(', ');
    final feeLabel = lender.feeValue <= 0
        ? null
        : lender.feeType == FeeType.flat
            ? '${Money.format(lender.feeValue)} fee'
            : feeBounds.isEmpty
                ? '${Percent.format(lender.feeValue)} fee'
                : '${Percent.format(lender.feeValue)} fee ($feeBounds)';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Dismissible(
        key: ValueKey(lender.id),
        direction: DismissDirection.endToStart,
        background: _deleteBackground(c),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) {
          sl<HapticService>().warning();
          ref.read(lenderRepositoryProvider).delete(lender.id);
        },
        child: AppCard(
          onTap: () =>
              context.push('/settings/lenders/add', extra: lender),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lender.name, style: context.text.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      [
                        lender.type.label,
                        if (lender.typicalRatePct > 0)
                          '${Percent.format(lender.typicalRatePct)} p.a.',
                        ?feeLabel,
                      ].join(' · '),
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.textLow),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground(AppColors c) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: c.cost.withValues(alpha: 0.18),
          borderRadius: AppRadius.brCard,
        ),
        child: Icon(Icons.delete_outline_rounded, color: c.cost),
      );

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove lender?'),
        content: Text('Remove ${lender.name} from the catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
