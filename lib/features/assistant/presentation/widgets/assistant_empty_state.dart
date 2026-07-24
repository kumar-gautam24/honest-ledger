import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_theme.dart';
import '../../assistant_config.dart';

/// The first-run canvas: a calm greeting and a few starter prompts. Deliberately
/// restrained — no icon-card grid — so it reads as an invitation, not a menu.
class AssistantEmptyState extends StatelessWidget {
  const AssistantEmptyState({
    super.key,
    required this.onPick,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// Sends the chosen starter prompt.
  final ValueChanged<String> onPick;
  final double topPadding;
  final double bottomPadding;

  // Short chip labels mapped to the fuller question that gets sent.
  static const _starters = <(IconData, String, String)>[
    (Icons.calendar_today_rounded, 'Due soon', "What's due soon?"),
    (Icons.pie_chart_outline_rounded, 'This month', 'What do I owe this month?'),
    (Icons.subscriptions_outlined, 'Subscriptions',
        'How much am I spending on subscriptions?'),
    (Icons.credit_card_rounded, 'My cards', 'Show my cards'),
  ];

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning.';
    if (h < 17) return 'Good afternoon.';
    return 'Good evening.';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        topPadding,
        AppSpacing.xl,
        bottomPadding,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.62,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(_greeting(), style: context.text.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask about your EMIs, subscriptions and cards — I read your '
              'money and answer in plain language.',
              style: context.text.bodyMedium?.copyWith(color: c.textMid),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final (icon, label, query) in _starters)
                  _StarterChip(
                    icon: icon,
                    label: label,
                    onTap: () => onPick(query),
                  ),
              ],
            ),
            if (kAssistantDemoMode) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Icon(Icons.science_outlined, size: 13, color: c.textLow),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      'Demo mode — answers use your real data; no AI model is '
                      'connected yet.',
                      style: context.text.bodySmall?.copyWith(color: c.textLow),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      borderRadius: AppRadius.brPill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          hapticTap();
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brPill,
            border: Border.all(color: c.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: c.accent),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: context.text.bodyMedium?.copyWith(color: c.textHi),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
