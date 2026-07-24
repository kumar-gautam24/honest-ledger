import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// One user turn: a compact, quiet chip aligned to the right. Deliberately
/// understated so the assistant's editorial reply is the thing you read.
class UserMessage extends StatelessWidget {
  const UserMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: c.accent.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.card),
              topRight: Radius.circular(AppRadius.card),
              bottomLeft: Radius.circular(AppRadius.card),
              bottomRight: Radius.circular(AppRadius.sm),
            ),
          ),
          child: Text(
            text,
            style: context.text.bodyLarge?.copyWith(color: c.textHi),
          ),
        ),
      ),
    );
  }
}
