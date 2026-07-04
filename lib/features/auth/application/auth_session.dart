import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_exceptions.dart';
import '../../../core/api/auth_token_store.dart';
import '../../../core/api/cloud_refresh_service.dart';
import '../../../core/di/injector.dart';
import '../../settings/presentation/controllers/income_controller.dart';
import '../data/auth_api.dart';
import 'auth_state.dart';

part 'auth_session.g.dart';

/// The signed-in state and the actions that change it. Collaborators come from
/// get_it (`sl<T>()`), matching the app's other controllers.
///
/// On a successful sign-in it triggers a full cloud pull (if the refresh service
/// is registered) — that is the "log in on a new device and your data appears"
/// moment. The app stays fully usable signed out.
@riverpod
class AuthSession extends _$AuthSession {
  AuthApi get _api => sl<AuthApi>();
  AuthTokenStore get _tokens => sl<AuthTokenStore>();

  @override
  AuthState build() => AuthState(email: _tokens.email);

  /// Log in with an existing account, then pull the account's data down.
  Future<bool> signIn(String email, String password) async {
    return _run(() async {
      final pair = await _api.login(email, password);
      await _tokens.save(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
        email: email,
      );
      state = AuthState(email: email);
      await _pullAfterSignIn();
    });
  }

  /// Create an account, then sign in with it.
  Future<bool> register(String email, String password) async {
    return _run(() async {
      await _api.register(email, password);
      final pair = await _api.login(email, password);
      await _tokens.save(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
        email: email,
      );
      state = AuthState(email: email);
      await _pullAfterSignIn();
    });
  }

  Future<void> signOut() async {
    final refresh = _tokens.refreshToken;
    if (refresh != null) {
      await _api.logout(refresh);
    }
    await _tokens.clear();
    state = const AuthState();
  }

  /// Runs [action] with busy/error bookkeeping. Returns whether it succeeded.
  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isBusy: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isBusy: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(isBusy: false, error: 'Something went wrong');
      return false;
    }
  }

  Future<void> _pullAfterSignIn() async {
    if (sl.isRegistered<CloudRefreshService>()) {
      await sl<CloudRefreshService>().pullAll();
      // Drift-backed views auto-update from their streams; income is prefs-backed,
      // so refresh it explicitly to reflect the pulled value immediately.
      ref.invalidate(incomeControllerProvider);
    }
  }
}
