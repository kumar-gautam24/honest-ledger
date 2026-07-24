import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The pre-stream indicator: three brass dots breathing in sequence, shown in
/// the assistant lane while the reply is being prepared (before the first word
/// arrives). Respects reduce-motion by holding the dots steady.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!reduceMotion && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: AppSpacing.md),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              children: List.generate(3, (i) {
                // Each dot peaks a third of a cycle after the previous one.
                final phase = (_controller.value - i * 0.2) % 1.0;
                final t = (phase < 0.5 ? phase : 1 - phase) * 2; // 0→1→0
                final alpha = 0.3 + 0.7 * Curves.easeInOut.transform(t);
                return Padding(
                  padding: const EdgeInsets.only(right: 6, top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: alpha),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
