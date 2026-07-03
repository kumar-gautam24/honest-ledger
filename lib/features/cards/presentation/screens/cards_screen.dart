import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/card_account.dart';
import '../../domain/entities/card_statement.dart';
import '../controllers/card_providers.dart';

/// Cards — my cards as ledger entries: this cycle's bill, its due date, and
/// utilization. Statement-level only; one number entered per month.
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider).asData?.value ?? const [];
    final statements =
        ref.watch(allCardStatementsProvider).asData?.value ?? const [];
    final loading = ref.watch(cardsProvider).isLoading;

    return AppScaffold(
      title: 'Cards',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          sl<HapticService>().select();
          context.push('/cards/add');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add card'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : cards.isEmpty
              ? EmptyState(
                  icon: Icons.credit_card_outlined,
                  title: 'No cards yet',
                  message: 'Add a card to track its monthly bill — one '
                      'number a month, EMIs split out automatically.',
                  actionLabel: 'Add card',
                  onAction: () => context.push('/cards/add'),
                )
              : ListView(
                  padding: AppSpacing.screen.copyWith(bottom: 96),
                  children: [
                    for (final (i, card) in cards.indexed) ...[
                      EntranceFade(
                        index: i,
                        child: _CardTile(
                          card: card,
                          statements: [
                            for (final s in statements)
                              if (s.cardId == card.id) s,
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.statements});

  final CardAccount card;

  /// This card's statements, newest first.
  final List<CardStatement> statements;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final currentCycle = now.monthStart;
    CardStatement? current;
    for (final s in statements) {
      if (s.cycleMonth.isSameMonth(currentCycle)) current = s;
    }
    final latestUnpaid =
        statements.where((s) => !s.isPaid).toList(growable: false);
    final showing = current ?? (latestUnpaid.isEmpty ? null : latestUnpaid.first);
    final utilization = (showing != null && card.creditLimit != null)
        ? (showing.statementAmount / card.creditLimit!).clamp(0.0, 1.0)
        : null;

    return AppCard(
      onTap: () {
        sl<HapticService>().select();
        context.push('/cards/${card.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card_rounded, color: c.accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(card.name, style: context.text.titleMedium),
              ),
              Icon(Icons.chevron_right_rounded, color: c.textLow),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (showing != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    showing.isPaid
                        ? 'Bill paid'
                        : 'Bill due ${relativeDueLabel(showing.dueDate).toLowerCase()}',
                    style: context.text.bodySmall?.copyWith(
                      color: showing.isPaid
                          ? c.positive
                          : showing.dueDate.daysFromNow < 0
                              ? c.cost
                              : c.textMid,
                    ),
                  ),
                ),
                MoneyText(showing.statementAmount),
              ],
            ),
          ] else
            Text(
              'No statement yet — generates on day ${card.statementDay}',
              style: context.text.bodySmall,
            ),
          if (utilization != null) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: AppRadius.brPill,
              child: SizedBox(
                height: 3,
                child: Stack(
                  children: [
                    Container(color: c.surfaceHigh),
                    FractionallySizedBox(
                      widthFactor: utilization,
                      child: Container(
                        color: utilization > 0.3 ? c.cost : c.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
