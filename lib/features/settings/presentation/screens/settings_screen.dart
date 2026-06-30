import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final controller = ref.read(themeModeControllerProvider.notifier);

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const SectionHeader('Appearance'),
          _ThemeSelector(
            mode: mode,
            onChanged: (m) {
              sl<HapticService>().select();
              controller.set(m);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('About'),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: context.text.titleMedium,
                  ),
                ),
                Text('v0.1.0', style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(value: ThemeMode.system, label: Text('System')),
        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        backgroundColor: c.surface,
        foregroundColor: c.textMid,
        selectedBackgroundColor: c.accent.withValues(alpha: 0.16),
        selectedForegroundColor: c.accent,
        side: BorderSide(color: c.hairline),
      ),
    );
  }
}
