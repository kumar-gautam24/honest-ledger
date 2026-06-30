import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../haptics/haptic_service.dart';

/// Global service locator. Holds app-lifetime singletons (services, database,
/// datasources, repositories). UI state stays in Riverpod; providers read their
/// collaborators from here via `sl<T>()`.
final GetIt sl = GetIt.instance;

/// Registers always-on singletons. Feature repositories/datasources are added
/// to this in their own phases.
Future<void> configureDependencies() async {
  if (!sl.isRegistered<HapticService>()) {
    sl.registerSingleton<HapticService>(HapticService());
  }
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    );
  }
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerSingleton<AppDatabase>(AppDatabase());
  }
}

/// Fires a light tap if haptics are available. Safe to call from widgets even
/// when DI is not configured (e.g. in widget tests).
void hapticTap() {
  if (sl.isRegistered<HapticService>()) sl<HapticService>().tap();
}
