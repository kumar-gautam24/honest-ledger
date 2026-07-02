import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../domain/entities/lender_waste.dart';
import '../home_providers.dart';

/// The Leak — the lifetime waste statement: what was borrowed, what came back,
/// what leaked away, and which lender is doing the leaking.
class WasteScreen extends ConsumerWidget {
  const WasteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final lifetime = ref.watch(lifetimeStatsProvider);
    final ranked = ref.watch(lenderWasteProvider);
    final isLeaking = lifetime.totalWasted > 0;

    return AppScaffold(
      title: 'The Leak',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          EntranceFade(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 1, color: c.hairline),
                const SizedBox(height: AppSpacing.lg),
                Text('LIFETIME WASTED', style: AppTypography.eyebrow(c)),
                const SizedBox(height: AppSpacing.sm),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedCounter(
                        value: lifetime.totalWasted,
                        formatter: Money.format,
                        style: AppTypography.moneyHero(
                          c,
                          color: isLeaking ? c.cost : c.textHi,
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
                const SizedBox(height: AppSpacing.lg),
                BreakdownRow(label: 'Borrowed', amount: lifetime.totalBorrowed),
                BreakdownRow(label: 'Repaid', amount: lifetime.totalRepaid),
                BreakdownRow(
                  label: 'Wasted so far',
                  amount: lifetime.totalWasted,
                  color: isLeaking ? c.cost : null,
                ),
                BreakdownRow(
                  label: 'Projected lifetime waste',
                  amount: lifetime.projectedWaste,
                  emphasise: true,
                  color: lifetime.projectedWaste > 0 ? c.cost : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(height: 1, color: c.hairline),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const EntranceFade(
            index: 1,
            child: SectionHeader('Where it leaks'),
          ),
          if (ranked.isEmpty)
            const EntranceFade(
              index: 2,
              child: EmptyState(
                icon: Icons.water_drop_outlined,
                title: 'No leaks yet',
                message: 'Once you track a borrowing, the lenders costing you '
                    'the most show up here.',
              ),
            )
          else
            for (final (i, lender) in ranked.indexed)
              EntranceFade(index: 2 + i, child: _LenderRow(lender: lender)),
        ],
      ),
    );
  }
}

class _LenderRow extends StatelessWidget {
  const _LenderRow({required this.lender});

  final LenderWaste lender;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lender.lenderName, style: context.text.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      lender.count == 1
                          ? '1 borrowing'
                          : '${lender.count} borrowings',
                      style: AppTypography.eyebrow(c).copyWith(
                        color: c.textLow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    lender.projectedExtra,
                    color: lender.projectedExtra > 0 ? c.cost : c.textMid,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Money.format(lender.wastedSoFar)} so far',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(height: 1, color: c.hairline),
      ],
    );
  }
}
