import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

/// Home tab — the money-leak dashboard. Phase 0 shows the signature hero with no
/// data yet; Phase 1 wires it to real borrowings and the repayment ledger.
class MoneyLeakScreen extends StatelessWidget {
  const MoneyLeakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: 'Recurring',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const _WastedHero(amount: 0, count: 0),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Borrowings'),
          EmptyState(
            icon: Icons.trending_down_rounded,
            title: 'Nothing tracked yet',
            message:
                'Add a borrowing — a Slice draw, a card EMI, a quick loan — '
                'and watch what it’s really costing you.',
            actionLabel: 'Add borrowing',
            onAction: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Borrowing entry arrives in the next phase.',
                    style: context.text.bodyMedium?.copyWith(color: c.textHi),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The signature element: the lifetime "wasted" figure as a printed ledger
/// line, with a brass rule above (statement total) and a fill underline.
class _WastedHero extends StatelessWidget {
  const _WastedHero({required this.amount, required this.count});

  final num amount;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLeaking = amount > 0;
    return Column(
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
                value: amount,
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
        const SizedBox(height: AppSpacing.sm),
        Text(
          count == 0
              ? 'across no borrowings — for now'
              : 'across $count ${count == 1 ? 'borrowing' : 'borrowings'}',
          style: context.text.bodyMedium,
        ),
      ],
    );
  }
}
