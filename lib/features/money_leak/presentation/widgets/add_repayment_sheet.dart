import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/validation/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/repayment.dart';
import '../../domain/repositories/borrowing_repository.dart';

const _uuid = Uuid();

/// Bottom sheet to log a repayment against a borrowing.
///
/// For a fixed EMI, pass the [installmentNo] being settled plus its exact
/// [prefillAmount] (still editable). For a flexible loan, pass [minAmount] to
/// enforce the minimum payment (there is no maximum).
Future<void> showAddRepaymentSheet(
  BuildContext context,
  String borrowingId, {
  int? installmentNo,
  double? prefillAmount,
  double minAmount = 0,
  String? context_,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AddRepaymentSheet(
      borrowingId: borrowingId,
      installmentNo: installmentNo,
      prefillAmount: prefillAmount,
      minAmount: minAmount,
      contextLabel: context_,
    ),
  );
}

class _AddRepaymentSheet extends StatefulWidget {
  const _AddRepaymentSheet({
    required this.borrowingId,
    this.installmentNo,
    this.prefillAmount,
    this.minAmount = 0,
    this.contextLabel,
  });

  final String borrowingId;
  final int? installmentNo;
  final double? prefillAmount;
  final double minAmount;

  /// A quiet line under the title, e.g. "Installment 3 · due 10 Aug".
  final String? contextLabel;

  @override
  State<_AddRepaymentSheet> createState() => _AddRepaymentSheetState();
}

class _AddRepaymentSheetState extends State<_AddRepaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: widget.prefillAmount == null
          ? ''
          : Money.input(widget.prefillAmount!),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repayment = Repayment(
      id: _uuid.v4(),
      borrowingId: widget.borrowingId,
      amount: double.parse(_amount.text.replaceAll(',', '').trim()),
      date: _date,
      installmentNo: widget.installmentNo,
    );
    await sl<BorrowingRepository>().addRepayment(repayment);
    sl<HapticService>().success();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record payment', style: context.text.titleLarge),
            if (widget.contextLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(widget.contextLabel!, style: context.text.bodySmall),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(
              label: 'Amount paid',
              controller: _amount,
              autofocus: true,
              textInputAction: TextInputAction.done,
              validator: Validators.combine([
                Validators.required('Enter the amount'),
                Validators.number(),
                Validators.positive(),
                if (widget.minAmount > 0)
                  Validators.min(
                    widget.minAmount,
                    message:
                        'Minimum payment is ${Money.format(widget.minAmount)}',
                  ),
              ]),
              onSubmitted: (_) => _add(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: c.surfaceHigh,
              onTap: _pickDate,
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: c.textMid),
                  const SizedBox(width: AppSpacing.md),
                  Text(_date.dayMonthYear, style: context.text.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Record payment', loading: _saving, onPressed: _add),
          ],
        ),
      ),
    );
  }
}
