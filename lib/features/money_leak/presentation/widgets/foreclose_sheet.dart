import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../lenders/domain/entities/lender.dart';
import '../../../lenders/presentation/lender_providers.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/entities/borrowing_summary.dart';
import '../../domain/entities/foreclosure.dart';
import '../../domain/entities/repayment.dart';
import '../controllers/money_leak_providers.dart';

const _uuid = Uuid();

/// Closes a fixed EMI early. Prices the payoff from the lender's own published
/// foreclosure rules — the charge, the GST on it, the interest accrued since the
/// last due date, and any settlement days the lender bills for — then records it
/// and marks the borrowing closed.
Future<void> showForecloseSheet(
  BuildContext context,
  WidgetRef ref,
  BorrowingSummary summary,
) {
  final lenderId = summary.borrowing.lenderId;
  final lenders =
      ref.read(allLendersProvider).asData?.value ?? const <Lender>[];
  Lender? lender;
  for (final l in lenders) {
    if (l.id == lenderId) lender = l;
  }
  final estimate = ForeclosureEstimate.of(summary: summary, lender: lender);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) =>
        _ForecloseSheet(summary: summary, ref: ref, estimate: estimate),
  );
}

class _ForecloseSheet extends StatefulWidget {
  const _ForecloseSheet({
    required this.summary,
    required this.ref,
    required this.estimate,
  });

  final BorrowingSummary summary;
  final WidgetRef ref;
  final ForeclosureEstimate estimate;

  @override
  State<_ForecloseSheet> createState() => _ForecloseSheetState();
}

class _ForecloseSheetState extends State<_ForecloseSheet> {
  late final TextEditingController _feeCtrl;

  @override
  void initState() {
    super.initState();
    final q = widget.estimate.quote;
    final charged = q.fee + q.gstOnFee;
    _feeCtrl =
        TextEditingController(text: charged > 0 ? Money.input(charged) : '');
    _feeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    super.dispose();
  }

  double get _fee =>
      double.tryParse(_feeCtrl.text.replaceAll(',', '').trim()) ?? 0;

  /// The stub interest is owed whatever the charge turns out to be.
  double get _cost => _fee + widget.estimate.quote.accruedInterest;

  Future<void> _confirm() async {
    final summary = widget.summary;
    final b = summary.borrowing;
    final repo = widget.ref.read(borrowingRepositoryProvider);
    final now = DateTime.now();
    await repo.upsertBorrowing(
      b.copyWith(status: BorrowingStatus.closed, foreclosureFee: _cost),
    );
    final payoff = summary.remainingPrincipal + _cost;
    if (payoff > 0) {
      await repo.addRepayment(Repayment(
        id: _uuid.v4(),
        borrowingId: b.id,
        amount: payoff,
        date: now,
        note: 'Foreclosure — closed early',
      ));
    }
    sl<HapticService>().success();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final e = widget.estimate;
    final q = e.quote;
    final principal = widget.summary.remainingPrincipal;
    final avoided = e.interestAvoided;
    final net = avoided - _cost;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foreclose EMI', style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(_blurb(e), style: context.text.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            BreakdownRow(label: 'Principal still owed', amount: principal),
            if (q.accruedInterest > 0)
              BreakdownRow(
                label: e.extraInterestDays > 0
                    ? 'Interest to settlement (+${e.extraInterestDays} day)'
                    : 'Interest since last due date',
                amount: q.accruedInterest,
              ),
            if (_fee > 0)
              BreakdownRow(label: 'Foreclosure charge', amount: _fee),
            const Divider(height: AppSpacing.xl),
            BreakdownRow(label: 'Pay today', amount: principal + _cost),
            const SizedBox(height: AppSpacing.lg),
            AppTextField.amount(
              label: e.rulesKnown
                  ? 'Foreclosure charge'
                  : 'Foreclosure charge (terms unknown)',
              controller: _feeCtrl,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              color: c.surfaceHigh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    net > 0 ? 'WORTH IT' : 'NOT WORTH IT',
                    style: AppTypography.eyebrow(c).copyWith(
                      color: net > 0 ? c.positive : c.cost,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    net > 0
                        ? 'Closing now dodges ${Money.format(avoided)} of interest '
                            'and costs ${Money.format(_cost)} — you keep '
                            '${Money.format(net)}.'
                        : 'Closing now dodges ${Money.format(avoided)} of interest '
                            'but costs ${Money.format(_cost)} — you lose '
                            '${Money.format(-net)}.',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Foreclose & close', onPressed: _confirm),
          ],
        ),
      ),
    );
  }
}

String _blurb(ForeclosureEstimate e) {
  if (e.insideFreeWindow) {
    return "You're inside your lender's free-cancellation window, so the "
        'charge is waived. The processing fee is not refunded.';
  }
  if (e.rulesKnown && e.quote.fee == 0 && e.extraInterestDays > 0) {
    return 'This lender charges nothing to foreclose, but bills '
        '${e.extraInterestDays} extra day of interest for settlement.';
  }
  if (!e.rulesKnown) {
    return "We don't have this lender's foreclosure terms. Enter the charge "
        'they quote you — the interest on the installments left is what you '
        'save.';
  }
  return "Pay off the principal, the interest accrued since your last due "
      "date, and your lender's charge. The interest on the installments left "
      'is what you save.';
}
