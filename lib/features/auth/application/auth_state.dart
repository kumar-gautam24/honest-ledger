/// Where a sign-in / register call is in its lifecycle. Drives the button
/// spinner ([authenticating]) and the full-screen sync moment ([syncing]).
enum AuthPhase {
  /// Nothing in flight.
  idle,

  /// Talking to the auth endpoint (login / register).
  authenticating,

  /// Credentials accepted; uploading local data and pulling the account down.
  syncing,
}

/// Whether the user is signed in to the cloud, and as whom. Signed out = null email.
/// The app is fully usable signed out (local-only); signing in adds cloud sync.
class AuthState {
  const AuthState({
    this.email,
    this.isBusy = false,
    this.error,
    this.phase = AuthPhase.idle,
  });

  final String? email;

  /// A sign-in / register call is in flight (drives the button spinner).
  final bool isBusy;

  /// Last sign-in/register failure message, for the form to show. Null when fine.
  final String? error;

  /// The current step of an in-flight call, so the UI can narrate it.
  final AuthPhase phase;

  bool get isSignedIn => email != null && email!.isNotEmpty;

  AuthState copyWith({
    String? email,
    bool? isBusy,
    String? error,
    AuthPhase? phase,
    bool clearEmail = false,
    bool clearError = false,
  }) {
    return AuthState(
      email: clearEmail ? null : (email ?? this.email),
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
      phase: phase ?? this.phase,
    );
  }
}
