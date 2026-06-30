import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/finance_math.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/widgets.dart';

/// Tools tab — the calculators. Each card carries a real worked example so the
/// payoff is visible before you even open it.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Live illustrative examples so the figures are honest, not mocked.
    final emi = FinanceMath.reducingEmi(50000, 14, 12);
    final trueCost =
        FinanceMath.noCostEmi(price: 10000, months: 9, bankAnnualRatePct: 36)
            .trueCost;

    return AppScaffold(
      body: ListView(
        padding: AppSpacing.screen.copyWith(top: AppSpacing.xl),
        children: [
          Text('TOOLS', style: AppTypography.eyebrow(c)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Run the numbers\nbefore you sign.',
            style: context.text.headlineMedium?.copyWith(height: 1.05),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _ToolCard(
            name: 'EMI Calculator',
            description:
                'Turn a price into a monthly EMI, total interest and a '
                'month-by-month schedule.',
            exampleLeft: '${Money.format(50000)} · 12m',
            exampleRight: '${Money.format(emi)}/mo',
            onTap: () => context.push('/tools/emi'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ToolCard(
            name: 'No-Cost EMI',
            description:
                "See what a '0%' offer truly costs once 18% GST and the "
                'processing fee leak through.',
            exampleLeft: '${Money.format(10000)} at 0%',
            exampleRight: '${Money.format(trueCost)} real',
            onTap: () => context.push('/tools/no-cost'),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.name,
    required this.description,
    required this.exampleLeft,
    required this.exampleRight,
    required this.onTap,
  });

  final String name;
  final String description;
  final String exampleLeft;
  final String exampleRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brass rule — the ledger tick down the side.
            Container(width: 3, color: c.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name, style: context.text.titleLarge),
                        ),
                        Icon(Icons.arrow_outward_rounded,
                            size: 20, color: c.accent),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(description, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceHigh,
                        borderRadius: AppRadius.brSm,
                      ),
                      child: Row(
                        children: [
                          Text(
                            exampleLeft,
                            style: AppTypography.money(c, color: c.textMid)
                                .copyWith(fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                            ),
                            child: Icon(Icons.arrow_right_alt_rounded,
                                size: 16, color: c.textLow),
                          ),
                          Text(
                            exampleRight,
                            style: AppTypography.money(c, color: c.accent)
                                .copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
