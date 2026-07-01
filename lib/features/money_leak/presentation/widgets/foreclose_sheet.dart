import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/entities/borrowing_summary.dart';
import '../../domain/entities/repayment.dart';
import '../controllers/money_leak_providers.dart';

const _uuid = Uuid();

/// Closes a fixed EMI early. Records the remaining principal as a payoff, stores
/// the foreclosure fee, and marks the borrowing closed. The card then shows the
/// interest the user avoided.
Future<void> showForecloseSheet(
  BuildContext context,
  WidgetRef ref,
  BorrowingSummary summary,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _ForecloseSheet(summary: summary, ref: ref),
  );
}

class _ForecloseSheet extends StatefulWidget {
  const _ForecloseSheet({required this.summary, required this.ref});

  final BorrowingSummary summary;
  final WidgetRef ref;

  @override
  State<_ForecloseSheet> createState() => _ForecloseSheetState();
}

class _ForecloseSheetState extends State<_ForecloseSheet> {
  final _feeCtrl = TextEditingController();

  @override
  void dispose() {
    _feeCtrl.dispose();
    super.dispose();
  }

  double get _fee =>
      double.tryParse(_feeCtrl.text.replaceAll(',', '').trim()) ?? 0;

  Future<void> _confirm() async {
    final summary = widget.summary;
    final b = summary.borrowing;
    final repo = widget.ref.read(borrowingRepositoryProvider);
    final now = DateTime.now();
    await repo.upsertBorrowing(
      b.copyWith(status: BorrowingStatus.closed, foreclosureFee: _fee),
    );
    final payoff = summary.remainingPrincipal + _fee;
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
    final payoff = widget.summary.remainingPrincipal;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Foreclose EMI', style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pay the remaining principal of ${Money.format(payoff)} to close this '
            'early. Add any foreclosure fee your lender charges — the interest on '
            'the installments left is what you save.',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField.amount(
            label: 'Foreclosure fee (optional)',
            controller: _feeCtrl,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Foreclose & close',
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}
