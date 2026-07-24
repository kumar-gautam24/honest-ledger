import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A quiet system line under the assistant's activity — "Checked your EMIs…",
/// "Saved.", "Cancelled.". Low-emphasis so it reads as a footnote, not a turn.
class StatusLine extends StatelessWidget {
  const StatusLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              text,
              style: context.text.bodySmall?.copyWith(
                color: c.textLow,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
