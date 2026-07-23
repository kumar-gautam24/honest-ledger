// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in state and the actions that change it. Collaborators come from
/// get_it (`sl<T>()`), matching the app's other controllers.
///
/// On a successful sign-in it triggers a full cloud pull (if the refresh service
/// is registered) — that is the "log in on a new device and your data appears"
/// moment. The app stays fully usable signed out.

@ProviderFor(AuthSession)
final authSessionProvider = AuthSessionProvider._();

/// The signed-in state and the actions that change it. Collaborators come from
/// get_it (`sl<T>()`), matching the app's other controllers.
///
/// On a successful sign-in it triggers a full cloud pull (if the refresh service
/// is registered) — that is the "log in on a new device and your data appears"
/// moment. The app stays fully usable signed out.
final class AuthSessionProvider
    extends $NotifierProvider<AuthSession, AuthState> {
  /// The signed-in state and the actions that change it. Collaborators come from
  /// get_it (`sl<T>()`), matching the app's other controllers.
  ///
  /// On a successful sign-in it triggers a full cloud pull (if the refresh service
  /// is registered) — that is the "log in on a new device and your data appears"
  /// moment. The app stays fully usable signed out.
  AuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionHash();

  @$internal
  @override
  AuthSession create() => AuthSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authSessionHash() => r'64bdb3ca9a764d7f939bb6bad5ddd02735a3e7b6';

/// The signed-in state and the actions that change it. Collaborators come from
/// get_it (`sl<T>()`), matching the app's other controllers.
///
/// On a successful sign-in it triggers a full cloud pull (if the refresh service
/// is registered) — that is the "log in on a new device and your data appears"
/// moment. The app stays fully usable signed out.

abstract class _$AuthSession extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
