import 'package:get_it/get_it.dart';

import '../haptics/haptic_service.dart';

/// Global service locator. Holds app-lifetime singletons (services, database,
/// datasources, repositories). UI state stays in Riverpod; providers read their
/// collaborators from here via `sl<T>()`.
final GetIt sl = GetIt.instance;

/// Registers the always-on core services. Feature/data registrations are added
/// in later phases (Drift database, Dio client, repositories).
Future<void> configureDependencies() async {
  if (!sl.isRegistered<HapticService>()) {
    sl.registerSingleton<HapticService>(HapticService());
  }
}

/// Fires a light tap if haptics are available. Safe to call from widgets even
/// when DI is not configured (e.g. in widget tests).
void hapticTap() {
  if (sl.isRegistered<HapticService>()) sl<HapticService>().tap();
}
