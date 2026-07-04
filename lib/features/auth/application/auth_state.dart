/// Whether the user is signed in to the cloud, and as whom. Signed out = null email.
/// The app is fully usable signed out (local-only); signing in adds cloud sync.
class AuthState {
  const AuthState({this.email, this.isBusy = false, this.error});

  final String? email;

  /// A sign-in / register call is in flight (drives the button spinner).
  final bool isBusy;

  /// Last sign-in/register failure message, for the form to show. Null when fine.
  final String? error;

  bool get isSignedIn => email != null && email!.isNotEmpty;

  AuthState copyWith({
    String? email,
    bool? isBusy,
    String? error,
    bool clearEmail = false,
    bool clearError = false,
  }) {
    return AuthState(
      email: clearEmail ? null : (email ?? this.email),
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
