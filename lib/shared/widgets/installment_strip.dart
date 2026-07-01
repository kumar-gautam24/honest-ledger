import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A compact ledger of EMI installments: one pip per month, read left to right
/// like a punch-card. Paid pips are filled brass, the next one due is ringed,
/// the rest are hollow. The honest counterpart to a continuous progress bar —
/// an EMI is a discrete sequence, so it's drawn as one.
class InstallmentStrip extends StatelessWidget {
  const InstallmentStrip({
    super.key,
    required this.total,
    required this.paid,
    this.next,
    this.height = 6,
  });

  final int total;
  final Set<int> paid;
  final int? next;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (total <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 3.0;
        final pipWidth =
            ((constraints.maxWidth - gap * (total - 1)) / total).clamp(2.0, 24.0);
        return Row(
          children: [
            for (var n = 1; n <= total; n++) ...[
              _Pip(
                width: pipWidth,
                height: height,
                filled: paid.contains(n),
                isNext: n == next,
                colors: c,
              ),
              if (n != total) const SizedBox(width: gap),
            ],
          ],
        );
      },
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip({
    required this.width,
    required this.height,
    required this.filled,
    required this.isNext,
    required this.colors,
  });

  final double width;
  final double height;
  final bool filled;
  final bool isNext;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Border? border;
    if (filled) {
      fill = colors.accent;
      border = null;
    } else if (isNext) {
      fill = colors.accent.withValues(alpha: 0.18);
      border = Border.all(color: colors.accent, width: 1);
    } else {
      fill = colors.surfaceHigh;
      border = null;
    }

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        border: border,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}
