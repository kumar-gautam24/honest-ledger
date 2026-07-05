import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';

/// The full-screen moment shown while a fresh sign-in uploads local data and
/// pulls the account down. Reuses the brand mark — the loop *is* the sync — so
/// it reads as a continuation of the launch moment rather than a spinner. It
/// covers the account screen underneath until the sync settles.
class SyncOverlay extends StatelessWidget {
  const SyncOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ColoredBox(
      color: c.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AnimatedBrandMark(size: 104),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Syncing your data',
              style: context.text.titleMedium?.copyWith(color: c.textHi),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Backing up what’s here, then bringing the rest down.',
              textAlign: TextAlign.center,
              style: context.text.bodySmall?.copyWith(color: c.textMid),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 132,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: c.accent,
                  backgroundColor: c.hairline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
