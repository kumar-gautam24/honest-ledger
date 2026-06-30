import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injector.dart';
import '../../core/haptics/haptic_service.dart';
import '../../features/money_leak/presentation/screens/money_leak_screen.dart';
import '../../features/recurring/presentation/screens/recurring_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/tools/presentation/screens/tools_screen.dart';

/// App routes. A persistent bottom-nav shell hosts the four top-level tabs;
/// feature detail routes are added under their branches in later phases.
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
              builder: (_, _) => const MoneyLeakScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/tools', builder: (_, _) => const ToolsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recurring',
              builder: (_, _) => const RecurringScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const SettingsScreen(),
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
            icon: Icon(Icons.trending_down_outlined),
            selectedIcon: Icon(Icons.trending_down_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_repeat_outlined),
            selectedIcon: Icon(Icons.event_repeat_rounded),
            label: 'Recurring',
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
