import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/forms/app_form.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../lenders/domain/entities/lender.dart';
import '../../../lenders/presentation/widgets/lender_picker.dart';
import '../../domain/entities/borrowing.dart';
import '../controllers/money_leak_providers.dart';

const _uuid = Uuid();

/// Create or edit a borrowing. Picking a lender autofills its typical rate and
/// fee; everything stays editable.
class AddEditBorrowingScreen extends ConsumerStatefulWidget {
  const AddEditBorrowingScreen({super.key, this.existing});

  final Borrowing? existing;

  @override
  ConsumerState<AddEditBorrowingScreen> createState() =>
      _AddEditBorrowingScreenState();
}

class _AddEditBorrowingScreenState
    extends ConsumerState<AddEditBorrowingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _principal;
  late final TextEditingController _fee;
  late final TextEditingController _rate;
  late final TextEditingController _tenure;
  late final TextEditingController _notes;

  RateType _rateType = RateType.reducing;
  late DateTime _startDate;
  Lender? _lender;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _principal = TextEditingController(text: e == null ? '' : _n(e.principal));
    _fee = TextEditingController(
      text: e == null || e.processingFee == 0 ? '' : _n(e.processingFee),
    );
    _rate = TextEditingController(
      text: e == null || e.interestRatePct == 0 ? '' : _n(e.interestRatePct),
    );
    _tenure = TextEditingController(
      text: e == null || e.tenureMonths == 0 ? '' : '${e.tenureMonths}',
    );
    _notes = TextEditingController(text: e?.notes ?? '');
    _rateType = e?.rateType ?? RateType.reducing;
    _startDate = e?.startDate ?? DateTime.now();
    // Live-update the EMI preview as figures change.
    for (final ctrl in [_principal, _rate, _tenure, _fee]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctrl in [_title, _principal, _fee, _rate, _tenure, _notes]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  Future<void> _pickLender() async {
    final lender = await showLenderPicker(context);
    if (lender == null) return;
    setState(() {
      _lender = lender;
      _rateType = lender.rateType;
      if (_rate.text.isEmpty && lender.typicalRatePct > 0) {
        _rate.text = _n(lender.typicalRatePct);
      }
      if (_fee.text.isEmpty &&
          lender.feeType == FeeType.flat &&
          lender.feeValue > 0) {
        _fee.text = _n(lender.feeValue);
      }
      if (_title.text.isEmpty) _title.text = lender.name;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      sl<HapticService>().warning();
      return;
    }
    setState(() => _saving = true);
    final fee = _parse(_fee);
    final existing = widget.existing;
    final borrowing = Borrowing(
      id: existing?.id ?? _uuid.v4(),
      title: _title.text.trim(),
      lenderId: _lender?.id ?? existing?.lenderId,
      lenderName: _lender?.name ?? existing?.lenderName ?? 'Other',
      principal: _parse(_principal),
      processingFee: fee,
      gstOnFee: fee * AppConstants.gstRate,
      interestRatePct: _parse(_rate),
      rateType: _rateType,
      tenureMonths: int.tryParse(_tenure.text.trim()) ?? 0,
      startDate: _startDate,
      status: existing?.status ?? BorrowingStatus.active,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    try {
      await ref.read(borrowingRepositoryProvider).upsertBorrowing(borrowing);
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
    return AppScaffold(
      title: _isEditing ? 'Edit borrowing' : 'Add borrowing',
      body: AppForm(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LenderField(lender: _lender, onTap: _pickLender),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'What is it for',
              controller: _title,
              hint: 'e.g. Phone, Slice draw',
              validator: Validators.required('Give it a name'),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(
              label: 'Amount borrowed',
              controller: _principal,
              validator: Validators.combine([
                Validators.required('Enter the amount'),
                Validators.number(),
                Validators.positive(),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Interest % p.a.',
                    controller: _rate,
                    hint: '0',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.number(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Tenure (months)',
                    controller: _tenure,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: Validators.integer(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(
              label: 'Processing fee',
              controller: _fee,
              validator: Validators.number(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Interest type', style: AppTypography.eyebrow(c)),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<RateType>(
              segments: const [
                ButtonSegment(
                  value: RateType.reducing,
                  label: Text('Reducing'),
                ),
                ButtonSegment(value: RateType.flat, label: Text('Flat')),
              ],
              selected: {_rateType},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                sl<HapticService>().select();
                setState(() => _rateType = s.first);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _DateField(date: _startDate, onTap: _pickDate),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Notes (optional)',
              controller: _notes,
              hint: 'Anything worth remembering',
              textInputAction: TextInputAction.done,
              validator: null,
            ),
            const SizedBox(height: AppSpacing.xl),
            _EmiPreview(
              principal: _parse(_principal),
              ratePct: _parse(_rate),
              months: int.tryParse(_tenure.text.trim()) ?? 0,
              fee: _parse(_fee),
              rateType: _rateType,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _isEditing ? 'Save changes' : 'Add borrowing',
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _LenderField extends StatelessWidget {
  const _LenderField({required this.lender, required this.onTap});

  final Lender? lender;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: c.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              lender?.name ?? 'Choose lender or card',
              style: lender == null
                  ? context.text.bodyMedium
                  : context.text.titleMedium,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textLow),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Start date', style: AppTypography.eyebrow(c)),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          onTap: onTap,
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: c.textMid),
              const SizedBox(width: AppSpacing.md),
              Text(date.dayMonthYear, style: context.text.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Live EMI estimate shown while entering figures.
class _EmiPreview extends StatelessWidget {
  const _EmiPreview({
    required this.principal,
    required this.ratePct,
    required this.months,
    required this.fee,
    required this.rateType,
  });

  final double principal;
  final double ratePct;
  final int months;
  final double fee;
  final RateType rateType;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (principal <= 0 || months <= 0) return const SizedBox.shrink();

    final b = FinanceMath.emiBreakdown(
      principal: principal,
      annualRatePct: ratePct,
      months: months,
      rateType: rateType,
      feeValue: fee,
    );
    return AppCard(
      color: c.surfaceHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTIMATE', style: AppTypography.eyebrow(c)),
          const SizedBox(height: AppSpacing.md),
          _row(context, 'Monthly EMI', b.emi),
          _row(context, 'Total interest', b.totalInterest, color: c.cost),
          if (fee > 0) _row(context, 'Fee + GST', b.processingFee + b.gstOnFee),
          const Divider(height: AppSpacing.xl),
          _row(context, 'Total payable', b.totalPayable, emphasise: true),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    double value, {
    Color? color,
    bool emphasise = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.text.bodyMedium),
          MoneyText(
            value,
            style: emphasise ? MoneyStyle.large : MoneyStyle.inline,
            color: color,
          ),
        ],
      ),
    );
  }
}
