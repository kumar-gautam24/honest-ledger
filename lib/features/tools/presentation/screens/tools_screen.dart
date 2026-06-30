import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Tools tab — the calculators hub. Routes are wired in their phases.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tools',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const SectionHeader('Before you borrow'),
          const _ToolCard(
            icon: Icons.calculate_rounded,
            title: 'EMI Calculator',
            subtitle: 'Price → monthly EMI, total interest, full schedule.',
          ),
          const SizedBox(height: AppSpacing.md),
          const _ToolCard(
            icon: Icons.price_check_rounded,
            title: 'No-Cost EMI Analyzer',
            subtitle: "See what a '0%' offer really costs after GST and fees.",
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$title arrives in the next phase.',
              style: context.text.bodyMedium?.copyWith(color: c.textHi),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.14),
              borderRadius: AppRadius.brSm,
            ),
            child: Icon(icon, color: c.accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }
}
