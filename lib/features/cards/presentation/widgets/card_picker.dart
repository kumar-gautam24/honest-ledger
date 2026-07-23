import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/card_account.dart';
import '../controllers/card_providers.dart';

/// The outcome of picking a card: either a [card] was chosen, or the user
/// explicitly cleared the link. A null result (sheet dismissed) leaves the
/// current selection untouched.
class CardPickResult {
  const CardPickResult(this.card);
  const CardPickResult.cleared() : card = null;

  final CardAccount? card;
}

/// Opens the user's cards as a bottom sheet and returns the chosen card, or a
/// cleared result for "Not linked". Returns null if dismissed without a choice.
Future<CardPickResult?> showCardPicker(BuildContext context) {
  return showModalBottomSheet<CardPickResult>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _CardPickerSheet(),
  );
}

class _CardPickerSheet extends ConsumerWidget {
  const _CardPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final cards = ref.watch(cardsProvider);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      ),
      child: SafeArea(
        child: cards.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              "Couldn't load your cards.",
              style: context.text.bodyMedium,
            ),
          ),
          data: (list) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              const SectionHeader('Link to card'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.link_off_rounded, color: c.textLow),
                title: Text('Not linked', style: context.text.titleMedium),
                subtitle: Text(
                  'Bill this on its own, not through a card',
                  style: context.text.bodySmall,
                ),
                onTap: () => Navigator.of(context)
                    .pop(const CardPickResult.cleared()),
              ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'No cards yet — add one from the Cards tab.',
                    style: context.text.bodySmall,
                  ),
                )
              else
                ...list.map((card) => _CardTile(card: card)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final CardAccount card;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.credit_card_rounded, color: c.accent),
      title: Text(card.name, style: context.text.titleMedium),
      subtitle: Text(
        'Statement day ${card.statementDay}',
        style: context.text.bodySmall,
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: c.textLow),
      onTap: () => Navigator.of(context).pop(CardPickResult(card)),
    );
  }
}
