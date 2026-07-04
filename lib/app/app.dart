import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/controllers/theme_controller.dart';
import '../shared/widgets/widgets.dart';
import 'router/app_router.dart';

class RecurringApp extends ConsumerWidget {
  const RecurringApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return LaunchOverlay(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
