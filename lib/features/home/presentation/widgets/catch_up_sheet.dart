import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/catch_up.dart';
import '../controllers/catch_up_controller.dart';

/// The catch-up sheet: every missed occurrence pre-checked; uncheck the
/// exceptions and settle the rest in one tap.
Future<void> showCatchUpSheet(BuildContext context, CatchUp catchUp) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CatchUpSheet(catchUp: catchUp),
  );
}

class _CatchUpSheet extends StatefulWidget {
  const _CatchUpSheet({required this.catchUp});

  final CatchUp catchUp;

  @override
  State<_CatchUpSheet> createState() => _CatchUpSheetState();
}

class _CatchUpSheetState extends State<_CatchUpSheet> {
  late final Set<CatchUpItem> _confirmed = {...widget.catchUp.items};
  var _saving = false;

  double get _total =>
      _confirmed.fold(0, (s, i) => s + i.amount);

  Future<void> _apply() async {
    if (_confirmed.isEmpty || _saving) return;
    setState(() => _saving = true);
    sl<HapticService>().success();
    await applyCatchUp(_confirmed.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: AppSpacing.screen.copyWith(
        bottom: AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('While you were away', style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'These went past without being logged. Uncheck anything you '
            'haven\'t actually paid.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in widget.catchUp.items)
                  CheckboxListTile(
                    value: _confirmed.contains(item),
                    onChanged: (checked) {
                      sl<HapticService>().select();
                      setState(() {
                        if (checked == true) {
                          _confirmed.add(item);
                        } else {
                          _confirmed.remove(item);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: c.accent,
                    title: Text(item.title, style: context.text.bodyLarge),
                    subtitle: Text(
                      item.installmentNo != null
                          ? '${item.dueDate.dayMonthYear} · '
                              'installment ${item.installmentNo}'
                          : item.dueDate.dayMonthYear,
                      style: context.text.bodySmall,
                    ),
                    secondary: MoneyText(item.amount),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _confirmed.isEmpty
                ? 'Mark paid'
                : 'Mark paid · ${Money.format(_total)}',
            onPressed: _confirmed.isEmpty || _saving ? null : _apply,
          ),
        ],
      ),
    );
  }
}
