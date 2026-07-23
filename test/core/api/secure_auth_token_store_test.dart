import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory [SecureKvStore] so we exercise the caching + migration logic
/// without touching platform channels.
class _FakeSecureKv implements SecureKvStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts signed out when secure storage is empty', () async {
    final store = await SecureAuthTokenStore.create(secure: _FakeSecureKv());
    expect(store.isSignedIn, isFalse);
    expect(store.accessToken, isNull);
  });

  test('save then read round-trips and marks signed in', () async {
    final store = await SecureAuthTokenStore.create(secure: _FakeSecureKv());
    await store.save(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      email: 'a@b.com',
    );
    expect(store.isSignedIn, isTrue);
    expect(store.accessToken, 'access-1');
    expect(store.refreshToken, 'refresh-1');
    expect(store.email, 'a@b.com');
  });

  test('written tokens survive a reload from the same backend', () async {
    final kv = _FakeSecureKv();
    final first = await SecureAuthTokenStore.create(secure: kv);
    await first.save(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      email: 'a@b.com',
    );
    // A fresh store over the same backend should load the persisted session.
    final second = await SecureAuthTokenStore.create(secure: kv);
    expect(second.isSignedIn, isTrue);
    expect(second.accessToken, 'access-1');
    expect(second.email, 'a@b.com');
  });

  test('updateAccessToken replaces only the access token', () async {
    final store = await SecureAuthTokenStore.create(secure: _FakeSecureKv());
    await store.save(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      email: 'a@b.com',
    );
    await store.updateAccessToken('access-2');
    expect(store.accessToken, 'access-2');
    expect(store.refreshToken, 'refresh-1');
  });

  test('clear signs out and wipes secure storage', () async {
    final kv = _FakeSecureKv();
    final store = await SecureAuthTokenStore.create(secure: kv);
    await store.save(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      email: 'a@b.com',
    );
    await store.clear();
    expect(store.isSignedIn, isFalse);
    expect(store.accessToken, isNull);
    // A reload confirms nothing was left behind.
    final reloaded = await SecureAuthTokenStore.create(secure: kv);
    expect(reloaded.isSignedIn, isFalse);
  });

  group('legacy migration from SharedPreferences', () {
    test('in-place upgrade moves plaintext tokens into secure storage and '
        'wipes prefs', () async {
      // Old version: tokens in plain prefs, secure store never used (no flag).
      SharedPreferences.setMockInitialValues({
        'auth_access_token': 'legacy-access',
        'auth_refresh_token': 'legacy-refresh',
        'auth_email': 'legacy@b.com',
      });
      final prefs = await SharedPreferences.getInstance();
      final kv = _FakeSecureKv();

      final store = await SecureAuthTokenStore.create(
        secure: kv,
        migrateFrom: prefs,
      );

      // Session preserved (user not logged out by the upgrade).
      expect(store.isSignedIn, isTrue);
      expect(store.accessToken, 'legacy-access');
      expect(store.refreshToken, 'legacy-refresh');
      expect(store.email, 'legacy@b.com');

      // Plaintext copies are gone; tokens now live in secure storage.
      expect(prefs.getString('auth_access_token'), isNull);
      expect(await kv.read('auth_access_token'), 'legacy-access');
      // The install flag is now set so later launches skip the fresh wipe.
      expect(prefs.getBool('secure_store_initialized'), isTrue);
    });

    test('fresh install with empty everything stays signed out', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = await SecureAuthTokenStore.create(
        secure: _FakeSecureKv(),
        migrateFrom: prefs,
      );
      expect(store.isSignedIn, isFalse);
      expect(prefs.getBool('secure_store_initialized'), isTrue);
    });
  });

  group('iOS Keychain survives uninstall (issue #88)', () {
    test('reinstall wipes orphaned Keychain tokens and starts signed out',
        () async {
      // Simulate: previous install left tokens in the Keychain, but uninstall
      // cleared SharedPreferences — so the install flag is absent.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final kv = _FakeSecureKv();
      await kv.write('auth_access_token', 'ghost-access');
      await kv.write('auth_refresh_token', 'ghost-refresh');
      await kv.write('auth_email', 'ghost@b.com');

      final store = await SecureAuthTokenStore.create(
        secure: kv,
        migrateFrom: prefs,
      );

      // The stale session must NOT come back to life.
      expect(store.isSignedIn, isFalse);
      expect(store.accessToken, isNull);
      // And the orphaned entries are wiped from the Keychain itself.
      expect(await kv.read('auth_access_token'), isNull);
      expect(prefs.getBool('secure_store_initialized'), isTrue);
    });

    test('normal relaunch (flag set) keeps the Keychain session', () async {
      // App already initialized once (flag set), with a live session.
      SharedPreferences.setMockInitialValues({
        'secure_store_initialized': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final kv = _FakeSecureKv();
      await kv.write('auth_access_token', 'live-access');
      await kv.write('auth_refresh_token', 'live-refresh');
      await kv.write('auth_email', 'live@b.com');

      final store = await SecureAuthTokenStore.create(
        secure: kv,
        migrateFrom: prefs,
      );

      // Not a fresh install → session is preserved.
      expect(store.isSignedIn, isTrue);
      expect(store.accessToken, 'live-access');
    });
  });
}
