import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/lender.dart';
import '../lender_providers.dart';

/// Opens the catalog as a bottom sheet and returns the chosen [Lender].
Future<Lender?> showLenderPicker(BuildContext context) {
  return showModalBottomSheet<Lender>(
    context: context,
    backgroundColor: context.colors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _LenderPickerSheet(),
  );
}

class _LenderPickerSheet extends ConsumerWidget {
  const _LenderPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lenders = ref.watch(allLendersProvider);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      ),
      child: SafeArea(
        child: lenders.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              "Couldn't load the catalog.",
              style: context.text.bodyMedium,
            ),
          ),
          data: (list) {
            final mine = list.where((l) => l.isMine).toList();
            final others = list.where((l) => !l.isMine).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                if (mine.isNotEmpty) ...[
                  const SectionHeader('My cards'),
                  ...mine.map((l) => _LenderTile(lender: l)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const SectionHeader('Catalog'),
                ...others.map((l) => _LenderTile(lender: l)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LenderTile extends StatelessWidget {
  const _LenderTile({required this.lender});

  final Lender lender;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(lender.name, style: context.text.titleMedium),
      subtitle: Text(
        '${lender.type.label} · ${Percent.format(lender.typicalRatePct)} p.a.',
        style: context.text.bodySmall,
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: c.textLow),
      onTap: () => Navigator.of(context).pop(lender),
    );
  }
}
