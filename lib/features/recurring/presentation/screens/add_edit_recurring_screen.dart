import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/forms/app_form.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../cards/domain/entities/card_account.dart';
import '../../../cards/presentation/controllers/card_providers.dart';
import '../../../cards/presentation/widgets/card_picker.dart';
import '../../domain/entities/recurring_item.dart';
import '../controllers/recurring_providers.dart';

const _uuid = Uuid();

class AddEditRecurringScreen extends ConsumerStatefulWidget {
  const AddEditRecurringScreen({super.key, this.existing, this.initialType});

  final RecurringItem? existing;

  /// Preset when arriving from the Home "Add" chooser (subscription vs bill).
  final RecurringType? initialType;

  @override
  ConsumerState<AddEditRecurringScreen> createState() =>
      _AddEditRecurringScreenState();
}

class _AddEditRecurringScreenState
    extends ConsumerState<AddEditRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _category;
  late final TextEditingController _notes;

  RecurringType _type = RecurringType.subscription;
  Frequency _frequency = Frequency.monthly;
  late DateTime _due;

  /// The card this item is billed on, when linked. Null stands on its own.
  String? _cardId;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _amount =
        TextEditingController(text: e == null ? '' : Money.input(e.amount));
    _category = TextEditingController(text: e?.category ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    // EMIs are tracked as borrowings now; treat any legacy EMI row as a bill.
    _type = e?.type == RecurringType.emi
        ? RecurringType.bill
        : e?.type ?? widget.initialType ?? RecurringType.subscription;
    _frequency = e?.frequency ?? Frequency.monthly;
    _due = e?.nextDueDate ?? DateTime.now().add(const Duration(days: 1));
    _cardId = e?.cardId;
  }

  @override
  void dispose() {
    for (final c in [_title, _amount, _category, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickCard() async {
    final result = await showCardPicker(context);
    if (result == null) return; // dismissed — leave selection untouched
    setState(() => _cardId = result.card?.id);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      sl<HapticService>().warning();
      return;
    }
    setState(() => _saving = true);
    final e = widget.existing;
    final item = RecurringItem(
      id: e?.id ?? _uuid.v4(),
      title: _title.text.trim(),
      type: _type,
      amount: double.parse(_amount.text.replaceAll(',', '').trim()),
      frequency: _frequency,
      nextDueDate: _due,
      category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      cardId: _cardId,
      isActive: e?.isActive ?? true,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      createdAt: e?.createdAt ?? DateTime.now(),
    );
    try {
      await ref.read(recurringRepositoryProvider).upsert(item);
      sl<HapticService>().success();
      if (mounted) context.pop();
    } catch (_) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cards =
        ref.watch(cardsProvider).asData?.value ?? const <CardAccount>[];
    CardAccount? selectedCard;
    for (final cc in cards) {
      if (cc.id == _cardId) selectedCard = cc;
    }
    return AppScaffold(
      title: _isEditing ? 'Edit item' : 'Add item',
      body: AppForm(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Name',
              controller: _title,
              hint: 'e.g. Netflix, Electricity bill',
              validator: Validators.required('Give it a name'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Type', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            _ChipRow<RecurringType>(
              values: const [RecurringType.subscription, RecurringType.bill],
              selected: _type,
              labelOf: (t) => t.label,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(label: 'Amount', controller: _amount),
            const SizedBox(height: AppSpacing.lg),
            Text('Frequency', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            _ChipRow<Frequency>(
              values: Frequency.values,
              selected: _frequency,
              labelOf: (f) => f.label,
              onChanged: (f) => setState(() => _frequency = f),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Next due date', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              onTap: _pickDate,
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: c.textMid),
                  const SizedBox(width: AppSpacing.md),
                  Text(_due.dayMonthYear, style: context.text.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Billed on card (optional)', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              onTap: _pickCard,
              child: Row(
                children: [
                  Icon(
                    selectedCard != null
                        ? Icons.credit_card_rounded
                        : Icons.credit_card_off_outlined,
                    color: selectedCard != null ? c.accent : c.textLow,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      selectedCard != null
                          ? 'Billed on ${selectedCard.name}'
                          : 'Not billed on a card',
                      style: selectedCard != null
                          ? context.text.titleMedium
                          : context.text.bodyMedium,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: c.textLow),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Category (optional)',
              controller: _category,
              hint: 'e.g. Entertainment, Utilities',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Notes (optional)',
              controller: _notes,
              hint: 'Anything worth remembering',
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _isEditing ? 'Save changes' : 'Add item',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(labelOf(v)),
            selected: v == selected,
            showCheckmark: false,
            backgroundColor: c.surface,
            selectedColor: c.accent.withValues(alpha: 0.16),
            side: BorderSide(
              color: v == selected ? c.accent : c.hairline,
            ),
            labelStyle: context.text.bodyMedium?.copyWith(
              color: v == selected ? c.accent : c.textMid,
            ),
            onSelected: (_) {
              sl<HapticService>().select();
              onChanged(v);
            },
          ),
      ],
    );
  }
}
