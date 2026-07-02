import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/forms/amount_input_formatter.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../controllers/haptics_controller.dart';
import '../controllers/income_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final themeController = ref.read(themeModeControllerProvider.notifier);
    final haptics = ref.watch(hapticsControllerProvider);

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
              themeController.set(m);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Haptic feedback', style: context.text.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Subtle taps on actions and selections',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: haptics,
                  onChanged: (v) {
                    ref.read(hapticsControllerProvider.notifier).set(v);
                    if (v) sl<HapticService>().success();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Planning'),
          const _IncomeTile(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Catalog'),
          _NavTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Cards & lenders',
            subtitle: 'Edit your cards and their rates and fees',
            onTap: () => context.push('/settings/lenders'),
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

/// Optional monthly income — powers "left after obligations" on Home and the
/// %-of-income line on This Month. Cleared by saving an empty amount.
class _IncomeTile extends ConsumerWidget {
  const _IncomeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final income = ref.watch(incomeControllerProvider);

    return AppCard(
      onTap: () => _edit(context, ref, income),
      child: Row(
        children: [
          Icon(Icons.account_balance_outlined, color: c.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly income', style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Shows what’s left after obligations',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          if (income != null)
            MoneyText(income)
          else
            Text('Not set', style: context.text.bodySmall),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    double? current,
  ) async {
    sl<HapticService>().select();
    final controller = TextEditingController(
      text: current == null ? '' : Money.input(current),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Monthly income'),
        content: AppTextField(
          label: 'Amount per month',
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [IndianAmountInputFormatter()],
          textInputAction: TextInputAction.done,
          autofocus: true,
          prefix: AppConstants.currencySymbol,
          onSubmitted: (_) => Navigator.of(dialogContext).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final value =
        double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
    sl<HapticService>().success();
    await ref
        .read(incomeControllerProvider.notifier)
        .set(value <= 0 ? null : value);
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: c.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: context.text.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
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
