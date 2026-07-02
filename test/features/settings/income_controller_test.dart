import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/features/settings/presentation/controllers/income_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  test('unset by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(incomeControllerProvider), isNull);
  });

  test('set persists across containers', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(incomeControllerProvider.notifier).set(85000);
    expect(container.read(incomeControllerProvider), 85000);

    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(fresh.read(incomeControllerProvider), 85000);
  });

  test('set null clears', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(incomeControllerProvider.notifier).set(85000);
    await container.read(incomeControllerProvider.notifier).set(null);
    expect(container.read(incomeControllerProvider), isNull);

    final fresh = ProviderContainer();
    addTearDown(fresh.dispose);
    expect(fresh.read(incomeControllerProvider), isNull);
  });

  test('non-positive value clears rather than storing junk', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(incomeControllerProvider.notifier).set(0);
    expect(container.read(incomeControllerProvider), isNull);
  });
}
