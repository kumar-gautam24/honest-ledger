import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A small eyebrow label that opens a section, with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.action});

  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label.toUpperCase(), style: AppTypography.eyebrow(c)),
          ),
          ?action,
        ],
      ),
    );
  }
}
