import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/cards/data/card_remote_source.dart';
import '../../features/cards/data/card_repository_impl.dart';
import '../../features/cards/data/synced_card_repository.dart';
import '../../features/cards/domain/repositories/card_repository.dart';
import '../../features/lenders/data/catalog_refresh_service.dart';
import '../../features/lenders/data/catalog_remote_source.dart';
import '../../features/lenders/data/lender_remote_source.dart';
import '../../features/lenders/data/lender_repository_impl.dart';
import '../../features/lenders/data/lender_seed.dart';
import '../../features/lenders/data/synced_lender_repository.dart';
import '../../features/lenders/domain/repositories/lender_repository.dart';
import '../../features/money_leak/data/borrowing_remote_source.dart';
import '../../features/money_leak/data/borrowing_repository_impl.dart';
import '../../features/money_leak/data/synced_borrowing_repository.dart';
import '../../features/money_leak/domain/repositories/borrowing_repository.dart';
import '../../features/assistant/assistant_config.dart';
import '../../features/assistant/data/ai_service.dart';
import '../../features/assistant/data/demo_ai_service.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/recurring/data/recurring_remote_source.dart';
import '../../features/recurring/data/recurring_repository_impl.dart';
import '../../features/recurring/data/synced_recurring_repository.dart';
import '../../features/recurring/domain/repositories/recurring_repository.dart';
import '../../features/settings/data/settings_remote_source.dart';
import '../api/api_client.dart';
import '../api/auth_token_store.dart';
import '../api/cloud_backed_repository.dart';
import '../api/cloud_refresh_service.dart';
import '../api/cloud_refresh_service_impl.dart';
import '../api/local_data_wiper.dart';
import '../database/app_database.dart';
import '../haptics/haptic_service.dart';

/// Global service locator. Holds app-lifetime singletons (services, database,
/// datasources, repositories). UI state stays in Riverpod; providers read their
/// collaborators from here via `sl<T>()`.
final GetIt sl = GetIt.instance;

/// Registers always-on singletons and seeds first-run data.
///
/// Pass [database] in tests to use an in-memory Drift database.
Future<void> configureDependencies({AppDatabase? database}) async {
  // Locale data for INR/date formatting (DateFormat with 'en_IN').
  await initializeDateFormatting();

  if (!sl.isRegistered<HapticService>()) {
    sl.registerSingleton<HapticService>(HapticService());
  }
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    );
  }
  // Apply the persisted haptics preference before any UI uses it.
  sl<HapticService>().enabled =
      sl<SharedPreferences>().getBool('haptics_enabled') ?? true;
  if (!sl.isRegistered<AppDatabase>()) {
    sl.registerSingleton<AppDatabase>(database ?? AppDatabase());
  }
  // API layer: token store -> Dio client -> auth API. Registered even when the
  // user is signed out; remote calls simply no-op without a token.
  if (!sl.isRegistered<AuthTokenStore>()) {
    sl.registerSingleton<AuthTokenStore>(
      // Tokens live in the OS secure enclave. On first launch after upgrading,
      // any tokens previously kept in plain SharedPreferences are migrated in
      // and their plaintext copies wiped, so the user stays signed in.
      await SecureAuthTokenStore.create(
        secure: FlutterSecureKvStore(),
        migrateFrom: sl<SharedPreferences>(),
      ),
    );
  }
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerSingleton<ApiClient>(ApiClient(sl<AuthTokenStore>()));
  }
  if (!sl.isRegistered<AuthApi>()) {
    sl.registerSingleton<AuthApi>(AuthApi(sl<ApiClient>()));
  }
  // AI assistant. In demo mode a local, no-network stand-in drives the flow so
  // the UX works with no model/key; otherwise the real proxy client calls
  // `/v1/ai/chat`, which holds the model key server-side.
  if (!sl.isRegistered<AiService>()) {
    sl.registerSingleton<AiService>(
      kAssistantDemoMode ? DemoAiService() : AiServiceDio(sl<ApiClient>()),
    );
  }
  if (!sl.isRegistered<SettingsRemoteSource>()) {
    sl.registerSingleton<SettingsRemoteSource>(
      SettingsRemoteSourceDio(sl<ApiClient>()),
    );
  }
  if (!sl.isRegistered<LenderRepository>()) {
    sl.registerSingleton<LenderRepository>(
      SyncedLenderRepository(
        LenderRepositoryImpl(sl<AppDatabase>()),
        LenderRemoteSourceDio(sl<ApiClient>()),
        sl<AuthTokenStore>(),
      ),
    );
  }
  if (!sl.isRegistered<BorrowingRepository>()) {
    sl.registerSingleton<BorrowingRepository>(
      SyncedBorrowingRepository(
        BorrowingRepositoryImpl(sl<AppDatabase>()),
        BorrowingRemoteSourceDio(sl<ApiClient>()),
        sl<AuthTokenStore>(),
      ),
    );
  }
  if (!sl.isRegistered<RecurringRepository>()) {
    sl.registerSingleton<RecurringRepository>(
      SyncedRecurringRepository(
        RecurringRepositoryImpl(sl<AppDatabase>()),
        RecurringRemoteSourceDio(sl<ApiClient>()),
        sl<AuthTokenStore>(),
      ),
    );
  }
  if (!sl.isRegistered<CardRepository>()) {
    sl.registerSingleton<CardRepository>(
      SyncedCardRepository(
        CardRepositoryImpl(sl<AppDatabase>()),
        CardRemoteSourceDio(sl<ApiClient>()),
        sl<AuthTokenStore>(),
      ),
    );
  }
  // The cross-feature pull orchestrator: every synced repo is a CloudBackedRepository.
  if (!sl.isRegistered<CloudRefreshService>()) {
    sl.registerSingleton<CloudRefreshService>(
      CloudRefreshServiceImpl(
        [
          sl<BorrowingRepository>() as CloudBackedRepository,
          sl<RecurringRepository>() as CloudBackedRepository,
          sl<CardRepository>() as CloudBackedRepository,
          sl<LenderRepository>() as CloudBackedRepository,
        ],
        sl<SettingsRemoteSource>(),
        sl<SharedPreferences>(),
        sl<AuthTokenStore>(),
      ),
    );
  }
  // Clears the account's local rows on sign-out (keeps the built-in catalog).
  if (!sl.isRegistered<LocalDataWiper>()) {
    sl.registerSingleton<LocalDataWiper>(
      LocalDataWiperImpl(sl<AppDatabase>(), sl<SharedPreferences>()),
    );
  }
  // Refreshes the built-in catalog from the server (public read) so term
  // corrections ship without an app update; writes to the LOCAL repository only.
  if (!sl.isRegistered<CatalogRefreshService>()) {
    sl.registerSingleton<CatalogRefreshService>(
      CatalogRefreshService(
        CatalogRemoteSourceDio(sl<ApiClient>()),
        LenderRepositoryImpl(sl<AppDatabase>()),
        sl<SharedPreferences>(),
      ),
    );
  }
  await _seedLenders();

  // Pull server catalog updates in the background: public read, safe when signed
  // out, never blocks startup, never throws (the seeded catalog stands in offline).
  unawaited(sl<CatalogRefreshService>().refresh());

  // If already signed in from a previous session, sync in the background so a
  // fresh launch both uploads anything that failed to push earlier and reflects
  // changes made on other devices. Push before pull (client is authoritative).
  // Fire-and-forget: never blocks startup, never throws.
  if (sl<AuthTokenStore>().isSignedIn) {
    final refresh = sl<CloudRefreshService>();
    unawaited(Future(() async {
      await refresh.pushAll();
      await refresh.pullAll();
    }));
  }
}

/// Seeds the lender catalog, and refreshes the built-in entries when the seed
/// data version changes (leaving user-added lenders alone).
Future<void> _seedLenders() async {
  final prefs = sl<SharedPreferences>();
  final storedVersion = prefs.getInt('lender_seed_version') ?? 0;
  if (storedVersion < kLenderSeedVersion) {
    await reseedLenders(sl<AppDatabase>());
    await prefs.setInt('lender_seed_version', kLenderSeedVersion);
  } else {
    await seedLendersIfEmpty(sl<AppDatabase>());
  }
}

/// Fires a light tap if haptics are available. Safe to call from widgets even
/// when DI is not configured (e.g. in widget tests).
void hapticTap() {
  if (sl.isRegistered<HapticService>()) sl<HapticService>().tap();
}
