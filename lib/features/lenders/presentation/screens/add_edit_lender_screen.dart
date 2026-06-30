import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/forms/app_form.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/lender.dart';
import '../lender_providers.dart';

const _uuid = Uuid();

/// Create or edit a catalog entry — a bank, card or BNPL app — including its
/// typical rate and processing fee. Everything here is user-editable.
class AddEditLenderScreen extends ConsumerStatefulWidget {
  const AddEditLenderScreen({super.key, this.existing});

  final Lender? existing;

  @override
  ConsumerState<AddEditLenderScreen> createState() =>
      _AddEditLenderScreenState();
}

class _AddEditLenderScreenState extends ConsumerState<AddEditLenderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _issuer;
  late final TextEditingController _network;
  late final TextEditingController _rate;
  late final TextEditingController _fee;
  late final TextEditingController _notes;

  LenderType _type = LenderType.card;
  RateType _rateType = RateType.reducing;
  FeeType _feeType = FeeType.flat;
  bool _isMine = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _issuer = TextEditingController(text: e?.issuer ?? '');
    _network = TextEditingController(text: e?.network ?? '');
    _rate = TextEditingController(
      text: e == null || e.typicalRatePct == 0 ? '' : _fmt(e.typicalRatePct),
    );
    _fee = TextEditingController(
      text: e == null || e.feeValue == 0 ? '' : _fmt(e.feeValue),
    );
    _notes = TextEditingController(text: e?.notes ?? '');
    _type = e?.type ?? LenderType.card;
    _rateType = e?.rateType ?? RateType.reducing;
    _feeType = e?.feeType ?? FeeType.flat;
    _isMine = e?.isMine ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _issuer, _network, _rate, _fee, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double _d(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      sl<HapticService>().warning();
      return;
    }
    setState(() => _saving = true);
    final e = widget.existing;
    final lender = Lender(
      id: e?.id ?? _uuid.v4(),
      name: _name.text.trim(),
      type: _type,
      issuer: _issuer.text.trim().isEmpty ? null : _issuer.text.trim(),
      network: _network.text.trim().isEmpty ? null : _network.text.trim(),
      typicalRatePct: _d(_rate),
      rateType: _rateType,
      feeType: _feeType,
      feeValue: _d(_fee),
      isMine: _isMine,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    await ref.read(lenderRepositoryProvider).upsert(lender);
    sl<HapticService>().success();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: _isEditing ? 'Edit lender' : 'Add lender',
      body: AppForm(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Name',
              controller: _name,
              hint: 'e.g. HDFC Swiggy',
              validator: Validators.required('Give it a name'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Type', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            _ChipRow<LenderType>(
              values: LenderType.values,
              selected: _type,
              labelOf: (t) => t.label,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Issuer (optional)',
                    controller: _issuer,
                    hint: 'HDFC',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Network (optional)',
                    controller: _network,
                    hint: 'RuPay',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Typical interest % p.a.',
              controller: _rate,
              hint: '0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Interest type', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            _ChipRow<RateType>(
              values: RateType.values,
              selected: _rateType,
              labelOf: (r) => r == RateType.reducing ? 'Reducing' : 'Flat',
              onChanged: (r) => setState(() => _rateType = r),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(
              label: _feeType == FeeType.flat
                  ? 'Processing fee (flat)'
                  : 'Processing fee (% of amount)',
              controller: _fee,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ChipRow<FeeType>(
              values: FeeType.values,
              selected: _feeType,
              labelOf: (f) => f == FeeType.flat ? 'Flat ₹' : 'Percent %',
              onChanged: (f) => setState(() => _feeType = f),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('One of my cards', style: context.text.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Show first when picking a lender',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isMine,
                    onChanged: (v) {
                      sl<HapticService>().select();
                      setState(() => _isMine = v);
                    },
                  ),
                ],
              ),
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
              label: _isEditing ? 'Save changes' : 'Add lender',
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
            side: BorderSide(color: v == selected ? c.accent : c.hairline),
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
