import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the app keeps the signed-in user's tokens.
///
/// An interface so the storage backend is swappable. Production uses
/// [SecureAuthTokenStore] (OS keychain / Keystore via `flutter_secure_storage`);
/// [SharedPrefsAuthTokenStore] is kept as the migration source and for simple
/// tests. Tokens must NOT live in plain SharedPreferences on a real build — they
/// are readable on a rooted/jailbroken device.
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

/// Plain-SharedPreferences store. No longer used at runtime (production uses
/// [SecureAuthTokenStore]); kept as the migration source and for simple tests.
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

/// A minimal async key/value contract over secure storage. Abstracting it keeps
/// [SecureAuthTokenStore] unit-testable with an in-memory fake, instead of
/// wiring platform channels in tests.
abstract interface class SecureKvStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// The real backend: OS keychain (iOS/macOS) / EncryptedSharedPreferences +
/// Keystore (Android), via the `flutter_secure_storage` package.
class FlutterSecureKvStore implements SecureKvStore {
  FlutterSecureKvStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              // On Android, back the store with the Keystore-encrypted store.
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Token store backed by the OS secure enclave.
///
/// The [AuthTokenStore] getters are synchronous but secure storage is async, so
/// this loads the three values into memory once (via [create]) and then serves
/// reads from that cache while writing through to secure storage.
class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore._(this._secure, this._access, this._refresh, this._email);

  final SecureKvStore _secure;
  String? _access;
  String? _refresh;
  String? _email;

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _emailKey = 'auth_email';

  /// Set once the secure store has run on this install. Lives in
  /// SharedPreferences (NSUserDefaults / Android prefs), which the OS *does*
  /// clear on uninstall — unlike the iOS/macOS Keychain. Its absence therefore
  /// means "fresh install", our signal to wipe any orphaned Keychain entries.
  static const _installFlag = 'secure_store_initialized';

  /// Loads tokens into memory, handling two platform quirks:
  ///
  /// 1. **iOS/macOS Keychain survives app uninstall** (flutter_secure_storage
  ///    issue #88 and friends). Without care, deleting and reinstalling the app
  ///    would silently restore the previous session — even a previous *user's*.
  ///    We detect a fresh install via a SharedPreferences flag (prefs ARE wiped
  ///    on uninstall) and, when it's missing, clear secure storage first.
  ///
  /// 2. **Legacy plaintext tokens.** Earlier builds kept tokens in plain
  ///    SharedPreferences. On upgrade we move them into secure storage and wipe
  ///    the plaintext copies, so an existing signed-in user is NOT logged out
  ///    and their tokens stop living in the clear.
  ///
  /// The two interact cleanly: on a genuine fresh install prefs holds no legacy
  /// tokens, so after the wipe the migration is a no-op and the app starts
  /// signed out. On an in-place upgrade the flag is absent but prefs still holds
  /// the legacy session, which is migrated and preserved.
  static Future<SecureAuthTokenStore> create({
    required SecureKvStore secure,
    SharedPreferences? migrateFrom,
  }) async {
    if (migrateFrom != null && !(migrateFrom.getBool(_installFlag) ?? false)) {
      // Fresh install (or first run of this version): purge any Keychain
      // entries orphaned by a prior install before trusting them.
      await secure.delete(_accessKey);
      await secure.delete(_refreshKey);
      await secure.delete(_emailKey);
      await migrateFrom.setBool(_installFlag, true);
    }

    var access = await secure.read(_accessKey);
    var refresh = await secure.read(_refreshKey);
    var email = await secure.read(_emailKey);

    if (migrateFrom != null) {
      final oldAccess = migrateFrom.getString(_accessKey);
      // Only migrate if secure storage doesn't already have a session.
      if ((access == null || access.isEmpty) &&
          oldAccess != null &&
          oldAccess.isNotEmpty) {
        final oldRefresh = migrateFrom.getString(_refreshKey);
        final oldEmail = migrateFrom.getString(_emailKey);
        await secure.write(_accessKey, oldAccess);
        if (oldRefresh != null) await secure.write(_refreshKey, oldRefresh);
        if (oldEmail != null) await secure.write(_emailKey, oldEmail);
        access = oldAccess;
        refresh = oldRefresh;
        email = oldEmail;
      }
      // Always clear any plaintext token copies left in SharedPreferences.
      await migrateFrom.remove(_accessKey);
      await migrateFrom.remove(_refreshKey);
      await migrateFrom.remove(_emailKey);
    }

    return SecureAuthTokenStore._(secure, access, refresh, email);
  }

  @override
  String? get accessToken => _access;

  @override
  String? get refreshToken => _refresh;

  @override
  String? get email => _email;

  @override
  bool get isSignedIn {
    final token = _access;
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    _access = accessToken;
    _refresh = refreshToken;
    _email = email;
    await _secure.write(_accessKey, accessToken);
    await _secure.write(_refreshKey, refreshToken);
    await _secure.write(_emailKey, email);
  }

  @override
  Future<void> updateAccessToken(String accessToken) async {
    _access = accessToken;
    await _secure.write(_accessKey, accessToken);
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _email = null;
    await _secure.delete(_accessKey);
    await _secure.delete(_refreshKey);
    await _secure.delete(_emailKey);
  }
}
