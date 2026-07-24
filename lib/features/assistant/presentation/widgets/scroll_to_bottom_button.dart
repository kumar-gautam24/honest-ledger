import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injector.dart';

/// The "jump to latest" affordance. It fades and scales in only when you've
/// scrolled up away from the bottom, and carries a small brass dot when new
/// content arrived while you were reading history.
class ScrollToBottomButton extends StatelessWidget {
  const ScrollToBottomButton({
    super.key,
    required this.visible,
    required this.hasUnread,
    required this.onTap,
  });

  final bool visible;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedScale(
        scale: visible ? 1 : 0.8,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: AppMotion.fast,
          child: Material(
            color: c.surfaceHigh,
            shape: CircleBorder(side: BorderSide(color: c.hairline)),
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.4),
            child: InkWell(
              onTap: () {
                hapticTap();
                onTap();
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.arrow_downward_rounded,
                        size: 20, color: c.textHi),
                    if (hasUnread)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surfaceHigh, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
