import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/data/settings_remote_source.dart';
import '../../features/settings/presentation/controllers/income_controller.dart';
import 'auth_token_store.dart';
import 'cloud_backed_repository.dart';
import 'cloud_refresh_service.dart';

/// Pulls the whole account down into the local cache. Called on sign-in and on
/// app start (when already signed in). Best-effort per feature: one feature
/// failing (or the whole backend being down) never aborts the others, and never
/// throws — the app keeps running on whatever is cached.
class CloudRefreshServiceImpl implements CloudRefreshService {
  CloudRefreshServiceImpl(this._repos, this._settings, this._prefs, this._tokens);

  final List<CloudBackedRepository> _repos;
  final SettingsRemoteSource _settings;
  final SharedPreferences _prefs;
  final AuthTokenStore _tokens;

  @override
  Future<void> pushAll() async {
    if (!_tokens.isSignedIn) return;
    for (final repo in _repos) {
      try {
        await repo.pushToCloud();
      } catch (_) {
        // Skip this feature; keep pushing the rest.
      }
    }
    await _pushIncome();
  }

  /// Uploads a locally-set income. Only pushes when a local value exists — a
  /// device with no income must never *clear* the cloud value during back-fill.
  Future<void> _pushIncome() async {
    final income = _prefs.getDouble(IncomeController.prefsKey);
    if (income == null) return;
    try {
      await _settings.pushIncome(income);
    } catch (_) {
      // Best-effort; the local value stays and can be pushed again later.
    }
  }

  @override
  Future<void> pullAll() async {
    if (!_tokens.isSignedIn) return;
    for (final repo in _repos) {
      try {
        await repo.pullFromCloud();
      } catch (_) {
        // Skip this feature; keep pulling the rest.
      }
    }
    await _pullIncome();
  }

  Future<void> _pullIncome() async {
    try {
      final income = await _settings.fetchIncome();
      if (income == null) {
        await _prefs.remove(IncomeController.prefsKey);
      } else {
        await _prefs.setDouble(IncomeController.prefsKey, income);
      }
    } catch (_) {
      // Leave the cached income as-is.
    }
  }
}
