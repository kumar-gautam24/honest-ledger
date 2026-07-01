import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injector.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/utils/enum_x.dart';
import '../../features/emi_calculator/presentation/screens/amortization_screen.dart';
import '../../features/emi_calculator/presentation/screens/emi_calculator_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lenders/domain/entities/lender.dart';
import '../../features/lenders/presentation/screens/add_edit_lender_screen.dart';
import '../../features/lenders/presentation/screens/lender_catalog_screen.dart';
import '../../features/money_leak/domain/entities/borrowing.dart';
import '../../features/money_leak/presentation/screens/add_edit_borrowing_screen.dart';
import '../../features/money_leak/presentation/screens/borrowing_detail_screen.dart';
import '../../features/no_cost_emi/presentation/screens/no_cost_emi_screen.dart';
import '../../features/recurring/domain/entities/recurring_item.dart';
import '../../features/recurring/presentation/screens/add_edit_recurring_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tools/presentation/screens/tools_screen.dart';

/// App routes. A persistent bottom-nav shell hosts the three top-level tabs
/// (Home · Tools · Settings). Home is the unified obligations hub; adding a
/// borrowing or recurring item lives under it with the kind/type preset.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _RootShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, state) => AddEditBorrowingScreen(
                    initialKind: enumByName(
                      BorrowingKind.values,
                      state.uri.queryParameters['kind'],
                      BorrowingKind.fixedEmi,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'add-recurring',
                  builder: (_, state) => AddEditRecurringScreen(
                    existing: state.extra as RecurringItem?,
                    initialType: enumByName(
                      RecurringType.values,
                      state.uri.queryParameters['type'],
                      RecurringType.subscription,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'borrowing/:id',
                  builder: (_, state) => BorrowingDetailScreen(
                    borrowingId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (_, state) => AddEditBorrowingScreen(
                        existing: state.extra as Borrowing?,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tools',
              builder: (_, _) => const ToolsScreen(),
              routes: [
                GoRoute(
                  path: 'emi',
                  builder: (_, _) => const EmiCalculatorScreen(),
                  routes: [
                    GoRoute(
                      path: 'schedule',
                      builder: (_, state) => AmortizationScreen(
                        args: state.extra as ScheduleArgs,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'no-cost',
                  builder: (_, _) => const NoCostEmiScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'lenders',
                  builder: (_, _) => const LenderCatalogScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      builder: (_, state) => AddEditLenderScreen(
                        existing: state.extra as Lender?,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _RootShell extends StatelessWidget {
  const _RootShell({required this.shell});

  final StatefulNavigationShell shell;

  void _onTap(int index) {
    sl<HapticService>().select();
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
