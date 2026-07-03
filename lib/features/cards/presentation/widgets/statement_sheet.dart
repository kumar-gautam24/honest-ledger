import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/forms/amount_input_formatter.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/card_account.dart';
import '../../domain/entities/card_cycle.dart';
import '../../domain/entities/card_statement.dart';
import '../../domain/repositories/card_repository.dart';

const _uuid = Uuid();

/// Enter or edit one cycle's statement — the single number a month this
/// feature asks for. The due date derives from the card's cycle.
Future<void> showStatementSheet(
  BuildContext context, {
  required CardAccount card,
  required DateTime cycleMonth,
  CardStatement? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _StatementSheet(
      card: card,
      cycleMonth: cycleMonth,
      existing: existing,
    ),
  );
}

class _StatementSheet extends StatefulWidget {
  const _StatementSheet({
    required this.card,
    required this.cycleMonth,
    this.existing,
  });

  final CardAccount card;
  final DateTime cycleMonth;
  final CardStatement? existing;

  @override
  State<_StatementSheet> createState() => _StatementSheetState();
}

class _StatementSheetState extends State<_StatementSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.existing == null
        ? ''
        : Money.input(widget.existing!.statementAmount),
  );
  var _saving = false;

  DateTime get _dueDate => CardCycle.dueDateFor(
        cycleMonth: widget.cycleMonth,
        statementDay: widget.card.statementDay,
        dueDay: widget.card.dueDay,
      );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount =
        double.tryParse(_amount.text.replaceAll(',', '').trim()) ?? 0;
    if (amount <= 0 || _saving) return;
    setState(() => _saving = true);
    final existing = widget.existing;
    sl<HapticService>().success();
    await sl<CardRepository>().upsertStatement(CardStatement(
      id: existing?.id ?? _uuid.v4(),
      cardId: widget.card.id,
      cycleMonth: widget.cycleMonth,
      statementAmount: amount,
      dueDate: existing?.dueDate ?? _dueDate,
      paidAmount: existing?.paidAmount ?? 0,
      paidDate: existing?.paidDate,
      notes: existing?.notes,
    ));
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
          Text(
            '${widget.card.name} — ${widget.cycleMonth.monthYear}',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'The bill total from your bank app. EMIs on this card are '
            'split out automatically.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Statement total',
            controller: _amount,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [IndianAmountInputFormatter()],
            textInputAction: TextInputAction.done,
            autofocus: true,
            prefix: AppConstants.currencySymbol,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Due ${(widget.existing?.dueDate ?? _dueDate).dayMonthYear}',
            style: context.text.bodySmall?.copyWith(color: c.textMid),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: widget.existing == null
                ? 'Save statement'
                : 'Update statement',
            onPressed: _saving ? null : _save,
            loading: _saving,
          ),
        ],
      ),
    );
  }
}
