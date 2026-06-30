import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../recurring/presentation/widgets/recurring_snapshot.dart';
import '../controllers/money_leak_providers.dart';
import '../widgets/borrowing_card.dart';

/// Home tab — the money-leak dashboard. The signature "wasted" hero sits above
/// the list of borrowings.
class MoneyLeakScreen extends ConsumerWidget {
  const MoneyLeakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(lifetimeStatsProvider);
    final summaries = ref.watch(borrowingSummariesProvider);

    return AppScaffold(
      title: 'Recurring',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/home/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: AppSpacing.screen.copyWith(bottom: 96),
        children: [
          _WastedHero(
            wasted: stats.totalWasted,
            projected: stats.projectedWaste,
            count: stats.count,
          ),
          const SizedBox(height: AppSpacing.xl),
          const RecurringSnapshot(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Borrowings'),
          summaries.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(
              "Couldn't load borrowings.",
              style: context.text.bodyMedium,
            ),
            data: (list) => list.isEmpty
                ? EmptyState(
                    icon: Icons.trending_down_rounded,
                    title: 'Nothing tracked yet',
                    message:
                        'Add a borrowing — a Slice draw, a card EMI, a quick '
                        'loan — and watch what it’s really costing you.',
                    actionLabel: 'Add borrowing',
                    onAction: () => context.push('/home/add'),
                  )
                : Column(
                    children: [
                      for (final (i, s) in list.indexed) ...[
                        EntranceFade(
                          index: i,
                          child: BorrowingCard(
                            summary: s,
                            onTap: () => context
                                .push('/home/borrowing/${s.borrowing.id}'),
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

/// The signature element: lifetime "wasted" as a ledger total with a brass rule
/// above and a fill underline, the figure rolling up on change.
class _WastedHero extends StatelessWidget {
  const _WastedHero({
    required this.wasted,
    required this.projected,
    required this.count,
  });

  final double wasted;
  final double projected;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLeaking = wasted > 0;
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
                value: wasted,
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
              : projected > wasted
                  ? '${Money.format(projected)} expected across $count '
                      '${count == 1 ? 'borrowing' : 'borrowings'}'
                  : 'across $count ${count == 1 ? 'borrowing' : 'borrowings'}',
          style: context.text.bodyMedium,
        ),
      ],
    );
  }
}
