import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// The app's button. Wraps Material buttons to add a light haptic on press and
/// an inline loading state, and to keep variants consistent.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isEnabled = onPressed != null && !loading;

    final VoidCallback? handler = isEnabled
        ? () {
            hapticTap();
            onPressed!();
          }
        : null;

    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? c.background
                  : c.accent,
            ),
          )
        : _content();

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
          onPressed: handler,
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: handler,
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textHi,
            side: BorderSide(color: c.hairline),
            // Height floor only — an infinite minimum width breaks in Rows.
            minimumSize: const Size(0, 52),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brInput,
            ),
          ),
          child: child,
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: handler,
          child: child,
        ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _content() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}
