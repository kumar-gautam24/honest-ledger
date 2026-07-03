import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../money_leak/domain/entities/borrowing_summary.dart';
import '../../../money_leak/presentation/controllers/money_leak_providers.dart';
import '../../domain/entities/card_account.dart';
import '../../domain/entities/card_cycle.dart';
import '../../domain/entities/card_statement.dart';
import '../../domain/repositories/card_repository.dart';
import '../controllers/card_providers.dart';
import '../widgets/statement_sheet.dart';

/// One card as a statement ledger: the current cycle's bill (or the CTA to
/// enter it), the EMI/spends split derived from one number, the month-by-month
/// history, and the EMIs running on this card.
class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsProvider).asData?.value ?? const [];
    final statements =
        ref.watch(cardStatementsProvider(cardId)).asData?.value ?? const [];
    final summaries =
        ref.watch(borrowingSummariesProvider).asData?.value ?? const [];

    CardAccount? card;
    for (final c in cards) {
      if (c.id == cardId) card = c;
    }
    if (card == null) {
      return const AppScaffold(
        title: 'Card',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final linkedEmis = [
      for (final s in summaries)
        if (s.isEmi && s.borrowing.lenderId == card.lenderId) s,
    ];

    return AppScaffold(
      title: card.name,
      actions: [
        IconButton(
          onPressed: () {
            sl<HapticService>().select();
            context.push('/cards/add', extra: card);
          },
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          EntranceFade(
            index: 0,
            child: _CurrentCycle(
              card: card,
              statements: statements,
              summaries: summaries,
            ),
          ),
          if (statements.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            const EntranceFade(index: 1, child: SectionHeader('History')),
            for (final (i, s) in statements.indexed)
              EntranceFade(
                index: 2 + i,
                child: _HistoryRow(
                  card: card,
                  statement: s,
                  summaries: summaries,
                  onTap: () => showStatementSheet(
                    context,
                    card: card!,
                    cycleMonth: s.cycleMonth,
                    existing: s,
                  ),
                ),
              ),
          ],
          if (linkedEmis.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            EntranceFade(
              index: 2 + statements.length,
              child: const SectionHeader('EMIs on this card'),
            ),
            for (final (i, s) in linkedEmis.indexed)
              EntranceFade(
                index: 3 + statements.length + i,
                child: _LinkedEmiRow(summary: s),
              ),
          ],
        ],
      ),
    );
  }
}

/// The current cycle: bill hero once entered, otherwise the enter-statement
/// invitation; EMI/spends split and utilization below.
class _CurrentCycle extends StatelessWidget {
  const _CurrentCycle({
    required this.card,
    required this.statements,
    required this.summaries,
  });

  final CardAccount card;
  final List<CardStatement> statements;
  final List<BorrowingSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cycle = CardCycle.cycleFor(
      now: DateTime.now(),
      statementDay: card.statementDay,
    );
    CardStatement? current;
    for (final s in statements) {
      if (s.cycleMonth.isSameMonth(cycle)) current = s;
    }
    final emiPortion = CardCycle.emiPortion(
      card: card,
      cycleMonth: cycle,
      summaries: summaries,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: c.hairline),
        const SizedBox(height: AppSpacing.lg),
        Text(cycle.monthYear.toUpperCase(), style: AppTypography.eyebrow(c)),
        const SizedBox(height: AppSpacing.lg),
        if (current == null) ...[
          Text(
            'Statement not entered yet',
            style: context.text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            emiPortion > 0
                ? 'At least ${Money.format(emiPortion)} of EMIs are on this '
                    'cycle. Enter the bill total to see the full picture.'
                : 'Enter the bill total from your bank app — one number, '
                    'the EMI split is derived.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Enter statement',
            expand: false,
            onPressed: () {
              sl<HapticService>().select();
              showStatementSheet(context, card: card, cycleMonth: cycle);
            },
          ),
        ] else ...[
          Text('BILL', style: AppTypography.eyebrow(c)),
          const SizedBox(height: AppSpacing.sm),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCounter(
                  value: current.statementAmount,
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
            label: 'EMIs on this bill',
            amount: CardCycle.emiPortion(
              card: card,
              cycleMonth: current.cycleMonth,
              summaries: summaries,
            ),
          ),
          BreakdownRow(
            label: 'Other spends',
            amount: CardCycle.otherSpends(
              current.statementAmount,
              CardCycle.emiPortion(
                card: card,
                cycleMonth: current.cycleMonth,
                summaries: summaries,
              ),
            ),
            emphasise: true,
          ),
          if (card.creditLimit != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${Percent.format(current.statementAmount / card.creditLimit! * 100, decimals: 0)} '
              'of the ${Money.compact(card.creditLimit!)} limit',
              style: context.text.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            current.isPaid
                ? 'Paid${current.paidDate != null ? ' on ${current.paidDate!.dayMonth}' : ''}'
                : 'Due ${relativeDueLabel(current.dueDate).toLowerCase()}',
            style: context.text.bodySmall?.copyWith(
              color: current.isPaid
                  ? c.positive
                  : current.dueDate.daysFromNow < 0
                      ? c.cost
                      : c.textMid,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!current.isPaid)
            AppButton(
              label: 'Mark bill paid',
              onPressed: () async {
                sl<HapticService>().success();
                await sl<CardRepository>().upsertStatement(
                  current!.copyWith(
                    paidAmount: current.statementAmount,
                    paidDate: DateTime.now(),
                  ),
                );
              },
            )
          else
            AppButton(
              label: 'Edit statement',
              variant: AppButtonVariant.secondary,
              onPressed: () {
                sl<HapticService>().select();
                showStatementSheet(
                  context,
                  card: card,
                  cycleMonth: current!.cycleMonth,
                  existing: current,
                );
              },
            ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Container(height: 1, color: c.hairline),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.card,
    required this.statement,
    required this.summaries,
    required this.onTap,
  });

  final CardAccount card;
  final CardStatement statement;
  final List<BorrowingSummary> summaries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final emiPortion = CardCycle.emiPortion(
      card: card,
      cycleMonth: statement.cycleMonth,
      summaries: summaries,
    );
    final spends = CardCycle.otherSpends(statement.statementAmount, emiPortion);

    return InkWell(
      onTap: () {
        sl<HapticService>().select();
        onTap();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    statement.cycleMonth.monthShort.toUpperCase(),
                    style: AppTypography.eyebrow(c),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${Money.format(emiPortion)} EMIs · '
                        '${Money.format(spends)} spends',
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statement.isPaid
                            ? 'Paid'
                            : 'Due ${statement.dueDate.dayMonth}',
                        style: context.text.bodySmall?.copyWith(
                          color: statement.isPaid ? c.positive : c.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
                MoneyText(statement.statementAmount),
              ],
            ),
          ),
          Container(height: 1, color: c.hairline),
        ],
      ),
    );
  }
}

class _LinkedEmiRow extends StatelessWidget {
  const _LinkedEmiRow({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: () {
        sl<HapticService>().select();
        context.push('/home/borrowing/${summary.borrowing.id}');
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.borrowing.title,
                        style: context.text.bodyLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.installmentLabel == null
                            ? 'EMI'
                            : 'EMI · ${summary.installmentLabel}',
                        style: AppTypography.eyebrow(c)
                            .copyWith(color: c.textLow),
                      ),
                    ],
                  ),
                ),
                if (summary.nextDueInstallment != null)
                  MoneyText(summary.nextDueInstallment!.total),
                Icon(Icons.chevron_right_rounded, color: c.textLow),
              ],
            ),
          ),
          Container(height: 1, color: c.hairline),
        ],
      ),
    );
  }
}
