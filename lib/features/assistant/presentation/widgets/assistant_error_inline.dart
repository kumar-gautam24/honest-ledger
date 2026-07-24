import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// An inline error in the assistant lane: what went wrong, plus a Retry that
/// re-runs the last turn. Direct, not apologetic — it tells you the next move.
class AssistantErrorInline extends StatelessWidget {
  const AssistantErrorInline({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: c.cost.withValues(alpha: 0.10),
          borderRadius: AppRadius.brCard,
          border: Border.all(color: c.cost.withValues(alpha: 0.30)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: c.cost),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: context.text.bodySmall?.copyWith(color: c.textHi),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: c.accent,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
