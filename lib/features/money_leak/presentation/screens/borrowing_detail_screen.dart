import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/entities/borrowing_summary.dart';
import '../../domain/entities/repayment.dart';
import '../controllers/money_leak_providers.dart';
import '../widgets/add_repayment_sheet.dart';

class BorrowingDetailScreen extends ConsumerWidget {
  const BorrowingDetailScreen({super.key, required this.borrowingId});

  final String borrowingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(borrowingSummaryProvider(borrowingId));
    final repo = ref.read(borrowingRepositoryProvider);

    return async.when(
      loading: () => const AppScaffold(
        title: 'Details',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => AppScaffold(
        title: 'Details',
        body: Center(
          child: Text("Couldn't load this borrowing.",
              style: context.text.bodyMedium),
        ),
      ),
      data: (summary) {
        if (summary == null) {
          return const AppScaffold(
            title: 'Details',
            body: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Not found',
              message: 'This borrowing no longer exists.',
            ),
          );
        }
        final b = summary.borrowing;
        return AppScaffold(
          title: b.title,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(
                '/home/borrowing/$borrowingId/edit',
                extra: b,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) => _onMenu(context, ref, repo, b, v),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'status',
                  child: Text(b.isClosed ? 'Mark active' : 'Mark closed'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
          floatingActionButton: b.isClosed
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => showAddRepaymentSheet(context, borrowingId),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add payment'),
                ),
          body: ListView(
            padding: AppSpacing.screen.copyWith(bottom: 96),
            children: [
              _SummaryCard(summary: summary),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader('Ledger'),
              _Ledger(summary: summary, onDelete: repo.deleteRepayment),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    WidgetRef ref,
    repo,
    Borrowing b,
    String action,
  ) async {
    if (action == 'status') {
      sl<HapticService>().select();
      await repo.upsertBorrowing(
        b.copyWith(
          status:
              b.isClosed ? BorrowingStatus.active : BorrowingStatus.closed,
        ),
      );
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete borrowing?'),
          content: const Text('This removes it and its whole ledger.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed ?? false) {
        sl<HapticService>().warning();
        await repo.deleteBorrowing(b.id);
        if (context.mounted) context.pop();
      }
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final BorrowingSummary summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = summary.borrowing;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(b.lenderName, style: AppTypography.eyebrow(c)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Borrowed', value: b.principal),
              _Stat(label: 'Repaid', value: summary.totalRepaid),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat(label: 'Outstanding', value: summary.outstanding),
              _Stat(
                label: 'Wasted',
                value: summary.wastedSoFar,
                color: summary.wastedSoFar > 0 ? c.cost : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ClipRRect(
            borderRadius: AppRadius.brPill,
            child: LinearProgressIndicator(
              value: summary.progress.toDouble(),
              minHeight: 6,
              backgroundColor: c.surfaceHigh,
              valueColor: AlwaysStoppedAnimation(c.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Scheduled total ${Money.format(summary.scheduledTotal)}',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          MoneyText(value, style: MoneyStyle.large, color: color),
        ],
      ),
    );
  }
}

class _Ledger extends StatelessWidget {
  const _Ledger({required this.summary, required this.onDelete});

  final BorrowingSummary summary;
  final Future<void> Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final repayments = [...summary.repayments]
      ..sort((a, b) => b.date.compareTo(a.date));

    if (repayments.isEmpty) {
      return Text(
        'No payments logged yet. Add one to start tracking the leak.',
        style: context.text.bodyMedium,
      );
    }

    return Column(
      children: [
        for (final r in repayments)
          _LedgerRow(repayment: r, onDelete: () => onDelete(r.id), color: c),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.repayment,
    required this.onDelete,
    required this.color,
  });

  final Repayment repayment;
  final VoidCallback onDelete;
  final AppColors color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, size: 18, color: color.textMid),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(repayment.date.dayMonthYear,
                style: context.text.bodyMedium),
          ),
          MoneyText(repayment.amount, color: color.positive),
          IconButton(
            icon: Icon(Icons.close_rounded, size: 18, color: color.textLow),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
