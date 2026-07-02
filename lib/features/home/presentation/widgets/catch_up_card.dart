import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/catch_up.dart';
import 'catch_up_sheet.dart';

/// The quiet "while you were away" statement card: shows what went past
/// unlogged and opens the catch-up sheet. Never blocks the app.
class CatchUpCard extends StatelessWidget {
  const CatchUpCard({super.key, required this.catchUp});

  final CatchUp catchUp;

  String get _summary {
    final parts = <String>[
      if (catchUp.emiCount > 0)
        catchUp.emiCount == 1
            ? '1 EMI installment'
            : '${catchUp.emiCount} EMI installments',
      if (catchUp.recurringCount > 0)
        catchUp.recurringCount == 1
            ? '1 bill'
            : '${catchUp.recurringCount} bills',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: () {
        sl<HapticService>().select();
        showCatchUpSheet(context, catchUp);
      },
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: c.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHILE YOU WERE AWAY',
                  style: AppTypography.eyebrow(c),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_summary, style: context.text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          MoneyText(catchUp.total),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }
}
