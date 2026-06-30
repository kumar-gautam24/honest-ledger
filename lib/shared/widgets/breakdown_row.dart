import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'money_text.dart';

/// A label-to-amount line used in result breakdowns (EMI, no-cost, detail).
/// Keeps every figure list aligned and styled the same way.
class BreakdownRow extends StatelessWidget {
  const BreakdownRow({
    super.key,
    required this.label,
    required this.amount,
    this.color,
    this.emphasise = false,
    this.signed = false,
  });

  final String label;
  final num amount;
  final Color? color;
  final bool emphasise;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final style = emphasise ? context.text.titleMedium : context.text.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(label, style: style)),
          MoneyText(
            amount,
            style: emphasise ? MoneyStyle.large : MoneyStyle.inline,
            color: color,
            signed: signed,
          ),
        ],
      ),
    );
  }
}
