import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_theme.dart';

/// The standard surface for grouped content. Optional [onTap] adds a light
/// haptic and ink response. A hairline border keeps cards legible on the
/// near-black background without heavy elevation.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.bordered = true,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool bordered;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: color ?? c.surface,
      borderRadius: AppRadius.brCard,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                hapticTap();
                onTap!();
              },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brCard,
            border: bordered
                ? Border.all(color: c.hairline, width: 1)
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
