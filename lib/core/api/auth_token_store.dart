import 'package:shared_preferences/shared_preferences.dart';

/// Where the app keeps the signed-in user's tokens.
///
/// An interface so the storage backend is swappable. We use SharedPreferences for
/// local development; before a real deployment this should move to
/// `flutter_secure_storage` (tokens in plain prefs are readable on a rooted device).
/// Swapping is a one-line DI change thanks to this interface.
abstract interface class AuthTokenStore {
  String? get accessToken;
  String? get refreshToken;
  String? get email;

  bool get isSignedIn;

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String email,
  });

  /// Replace just the access token (after a silent refresh), keeping the rest.
  Future<void> updateAccessToken(String accessToken);

  Future<void> clear();
}

class SharedPrefsAuthTokenStore implements AuthTokenStore {
  SharedPrefsAuthTokenStore(this._prefs);

  final SharedPreferences _prefs;

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _emailKey = 'auth_email';

  @override
  String? get accessToken => _prefs.getString(_accessKey);

  @override
  String? get refreshToken => _prefs.getString(_refreshKey);

  @override
  String? get email => _prefs.getString(_emailKey);

  @override
  bool get isSignedIn {
    final token = accessToken;
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
    await _prefs.setString(_emailKey, email);
  }

  @override
  Future<void> updateAccessToken(String accessToken) async {
    await _prefs.setString(_accessKey, accessToken);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_emailKey);
  }
}
