import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/haptics/haptic_service.dart';
import 'package:recurring/features/settings/presentation/controllers/haptics_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  test('toggling haptics flips HapticService and persists', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Defaults on.
    expect(container.read(hapticsControllerProvider), isTrue);
    expect(sl<HapticService>().enabled, isTrue);

    await container.read(hapticsControllerProvider.notifier).set(false);

    expect(container.read(hapticsControllerProvider), isFalse);
    expect(sl<HapticService>().enabled, isFalse);
    expect(sl<SharedPreferences>().getBool('haptics_enabled'), isFalse);
  });
}
