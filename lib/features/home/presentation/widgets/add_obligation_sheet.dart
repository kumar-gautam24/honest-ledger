import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// The four things you can add from Home. Each routes to the right form with the
/// kind/type preset, so the forms stay single-purpose.
enum _AddChoice {
  emi('EMI', 'Fixed monthly installments', Icons.account_balance_rounded,
      '/home/add?kind=fixedEmi'),
  loan('Loan', 'Pay any amount, anytime', Icons.bolt_rounded,
      '/home/add?kind=flexibleLoan'),
  subscription('Subscription', 'Netflix, Spotify, iCloud…',
      Icons.subscriptions_rounded, '/home/add-recurring?type=subscription'),
  bill('Bill', 'Rent, electricity, internet…', Icons.receipt_long_rounded,
      '/home/add-recurring?type=bill');

  const _AddChoice(this.label, this.subtitle, this.icon, this.route);
  final String label;
  final String subtitle;
  final IconData icon;
  final String route;
}

/// Bottom sheet to pick what to add from the Home tab.
Future<void> showAddObligationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _AddObligationSheet(),
  );
}

class _AddObligationSheet extends StatelessWidget {
  const _AddObligationSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add', style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            for (final choice in _AddChoice.values) ...[
              _ChoiceRow(choice: choice),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({required this.choice});

  final _AddChoice choice;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      color: c.surfaceHigh,
      onTap: () {
        sl<HapticService>().select();
        Navigator.of(context).pop();
        context.push(choice.route);
      },
      child: Row(
        children: [
          Icon(choice.icon, color: c.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(choice.label, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(choice.subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }
}
