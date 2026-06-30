import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money_formatter.dart';

enum MoneyStyle { inline, large, hero }

/// Renders a rupee figure in JetBrains Mono with tabular figures, in one of the
/// three money type sizes. The single place money is turned into a widget.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.style = MoneyStyle.inline,
    this.color,
    this.signed = false,
    this.compact = false,
  });

  final num amount;
  final MoneyStyle style;
  final Color? color;
  final bool signed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = compact
        ? Money.compact(amount)
        : signed
            ? Money.signed(amount)
            : Money.format(amount);

    final textStyle = switch (style) {
      MoneyStyle.inline => AppTypography.money(c, color: color),
      MoneyStyle.large => AppTypography.moneyLarge(c, color: color),
      MoneyStyle.hero => AppTypography.moneyHero(c, color: color),
    };

    return Text(text, style: textStyle);
  }
}
