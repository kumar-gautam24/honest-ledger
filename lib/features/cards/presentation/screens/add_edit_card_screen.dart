import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/forms/amount_input_formatter.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../lenders/domain/entities/lender.dart';
import '../../../lenders/presentation/lender_providers.dart';
import '../../domain/entities/card_account.dart';
import '../../domain/repositories/card_repository.dart';

const _uuid = Uuid();

/// Add or edit a card: pick which catalog card it is, set its billing cycle
/// (statement day, due day) and an optional credit limit.
class AddEditCardScreen extends ConsumerStatefulWidget {
  const AddEditCardScreen({super.key, this.existing});

  final CardAccount? existing;

  @override
  ConsumerState<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends ConsumerState<AddEditCardScreen> {
  late final TextEditingController _limit;
  String? _lenderId;
  int _statementDay = 1;
  int _dueDay = 20;
  var _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _lenderId = e?.lenderId;
    _statementDay = e?.statementDay ?? 1;
    _dueDay = e?.dueDay ?? 20;
    _limit = TextEditingController(
      text: e?.creditLimit == null ? '' : Money.input(e!.creditLimit!),
    );
  }

  @override
  void dispose() {
    _limit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_lenderId == null || _saving) return;
    setState(() => _saving = true);
    final limit =
        double.tryParse(_limit.text.replaceAll(',', '').trim()) ?? 0;
    final existing = widget.existing;
    final card = CardAccount(
      id: existing?.id ?? _uuid.v4(),
      lenderId: _lenderId!,
      name: '', // resolved from the catalog on read
      statementDay: _statementDay,
      dueDay: _dueDay,
      creditLimit: limit <= 0 ? null : limit,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    sl<HapticService>().success();
    await sl<CardRepository>().upsertCard(card);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lenders = ref.watch(allLendersProvider).asData?.value ?? const [];
    // My cards first — that's what this screen is for.
    final sorted = [...lenders]..sort((a, b) {
        if (a.isMine != b.isMine) return a.isMine ? -1 : 1;
        return a.name.compareTo(b.name);
      });

    return AppScaffold(
      title: _isEditing ? 'Edit card' : 'Add card',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          const SectionHeader('Which card'),
          for (final lender in sorted)
            _LenderChoice(
              lender: lender,
              selected: lender.id == _lenderId,
              onTap: () {
                sl<HapticService>().select();
                setState(() => _lenderId = lender.id);
              },
            ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Billing cycle'),
          _DayPickerRow(
            label: 'Statement day',
            hint: 'Day the bill is generated',
            value: _statementDay,
            onChanged: (d) => setState(() => _statementDay = d),
          ),
          const SizedBox(height: AppSpacing.md),
          _DayPickerRow(
            label: 'Due day',
            hint: 'Day the payment is due',
            value: _dueDay,
            onChanged: (d) => setState(() => _dueDay = d),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader('Limit (optional)'),
          AppTextField(
            label: 'Credit limit',
            controller: _limit,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [IndianAmountInputFormatter()],
            textInputAction: TextInputAction.done,
            prefix: AppConstants.currencySymbol,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: _isEditing ? 'Save card' : 'Add card',
            onPressed: _lenderId == null || _saving ? null : _save,
            loading: _saving,
          ),
          if (_lenderId == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Pick which card this is first',
                style: context.text.bodySmall?.copyWith(color: c.textLow),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LenderChoice extends StatelessWidget {
  const _LenderChoice({
    required this.lender,
    required this.selected,
    required this.onTap,
  });

  final Lender lender;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brCard,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? c.accent.withValues(alpha: 0.12) : c.surface,
            borderRadius: AppRadius.brCard,
            border: Border.all(color: selected ? c.accent : c.hairline),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 18,
                color: selected ? c.accent : c.textLow,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(lender.name, style: context.text.bodyLarge),
              ),
              if (lender.isMine)
                Text('MINE', style: AppTypography.eyebrow(c)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayPickerRow extends StatelessWidget {
  const _DayPickerRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(hint, style: context.text.bodySmall),
              ],
            ),
          ),
          DropdownButton<int>(
            value: value,
            underline: const SizedBox.shrink(),
            dropdownColor: c.surfaceHigh,
            items: [
              for (var d = 1; d <= 31; d++)
                DropdownMenuItem(value: d, child: Text('$d')),
            ],
            onChanged: (d) {
              if (d == null) return;
              sl<HapticService>().select();
              onChanged(d);
            },
          ),
        ],
      ),
    );
  }
}
