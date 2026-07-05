import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_exceptions.dart';
import '../../../core/api/auth_token_store.dart';
import '../../../core/api/cloud_refresh_service.dart';
import '../../../core/api/local_data_wiper.dart';
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

  /// Log in with an existing account, then sync the account's data.
  Future<bool> signIn(String email, String password) async {
    return _run(() async {
      final pair = await _api.login(email, password);
      await _tokens.save(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
        email: email,
      );
      state = state.copyWith(email: email);
      await _syncAfterSignIn();
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
      state = state.copyWith(email: email);
      await _syncAfterSignIn();
    });
  }

  /// Sign out and clear this account's data from the device, so signing into a
  /// different account can't inherit — or upload — the previous one's rows. A
  /// best-effort push runs first so any change that never synced still reaches
  /// the cloud. Everything after the network calls is local and always runs, so
  /// sign-out never gets stuck on a bad connection.
  Future<void> signOut() async {
    if (sl.isRegistered<CloudRefreshService>()) {
      try {
        await sl<CloudRefreshService>().pushAll();
      } catch (_) {
        // Best-effort; proceed to sign out regardless.
      }
    }
    final refresh = _tokens.refreshToken;
    if (refresh != null) {
      try {
        await _api.logout(refresh);
      } catch (_) {
        // Server may be unreachable; the local session still ends.
      }
    }
    await _tokens.clear();
    if (sl.isRegistered<LocalDataWiper>()) {
      await sl<LocalDataWiper>().wipe();
    }
    ref.invalidate(incomeControllerProvider);
    state = const AuthState();
  }

  /// Runs [action] with busy/phase/error bookkeeping. Returns whether it
  /// succeeded. Starts in the [AuthPhase.authenticating] phase; [action] moves
  /// it to [AuthPhase.syncing] itself once credentials are accepted.
  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(
      isBusy: true,
      phase: AuthPhase.authenticating,
      clearError: true,
    );
    try {
      await action();
      state = state.copyWith(isBusy: false, phase: AuthPhase.idle);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
          isBusy: false, phase: AuthPhase.idle, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
          isBusy: false, phase: AuthPhase.idle, error: 'Something went wrong');
      return false;
    }
  }

  /// After the token is saved: back-fill local data up (so anything created
  /// while signed out reaches the cloud instead of orphaning), then pull the
  /// account down. Push before pull — the client is authoritative, so uploading
  /// first means the pull merges back a cloud that already has the local rows.
  /// Both are best-effort and never throw, so a flaky network never fails a
  /// sign-in the credentials already earned.
  Future<void> _syncAfterSignIn() async {
    if (!sl.isRegistered<CloudRefreshService>()) return;
    state = state.copyWith(phase: AuthPhase.syncing);
    final service = sl<CloudRefreshService>();
    await service.pushAll();
    await service.pullAll();
    // Drift-backed views auto-update from their streams; income is prefs-backed,
    // so refresh it explicitly to reflect the pulled value immediately.
    ref.invalidate(incomeControllerProvider);
  }
}
