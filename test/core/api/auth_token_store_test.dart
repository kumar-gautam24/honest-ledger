import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPrefsAuthTokenStore> makeStore() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefsAuthTokenStore(prefs);
  }

  test('starts signed out', () async {
    final store = await makeStore();
    expect(store.isSignedIn, isFalse);
    expect(store.accessToken, isNull);
  });

  test('save then read round-trips tokens and marks signed in', () async {
    final store = await makeStore();
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

  test('updateAccessToken replaces only the access token', () async {
    final store = await makeStore();
    await store.save(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      email: 'a@b.com',
    );
    await store.updateAccessToken('access-2');
    expect(store.accessToken, 'access-2');
    expect(store.refreshToken, 'refresh-1');
  });

  test('clear signs out', () async {
    final store = await makeStore();
    await store.save(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      email: 'a@b.com',
    );
    await store.clear();
    expect(store.isSignedIn, isFalse);
    expect(store.accessToken, isNull);
    expect(store.email, isNull);
  });
}
