import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/api_client.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/api/cloud_refresh_service.dart';
import 'package:recurring/core/api/local_data_wiper.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/features/auth/application/auth_session.dart';
import 'package:recurring/features/auth/data/auth_api.dart';

class _MemTokenStore implements AuthTokenStore {
  String? _a, _r, _m;
  @override
  String? get accessToken => _a;
  @override
  String? get refreshToken => _r;
  @override
  String? get email => _m;
  @override
  bool get isSignedIn => _a != null;
  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    _a = accessToken;
    _r = refreshToken;
    _m = email;
  }

  @override
  Future<void> updateAccessToken(String accessToken) async => _a = accessToken;
  @override
  Future<void> clear() async => _a = _r = _m = null;
}

class _AuthAdapter implements HttpClientAdapter {
  _AuthAdapter({this.loginSucceeds = true});
  bool loginSucceeds;

  ResponseBody _json(Map<String, dynamic> body, int status) =>
      ResponseBody.fromString(jsonEncode(body), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? s,
      Future<void>? c) async {
    switch (options.path) {
      case '/v1/auth/register':
        return _json({'id': 'u1', 'email': 'a@b.com', 'created_at': '2026-01-01T00:00:00Z'}, 201);
      case '/v1/auth/login':
        if (loginSucceeds) {
          return _json({'access_token': 'acc', 'refresh_token': 'ref'}, 200);
        }
        return _json({'error': {'code': 'invalid_credentials', 'message': 'Bad email or password'}}, 401);
      case '/v1/auth/logout':
        return _json({}, 204);
      default:
        return _json({}, 200);
    }
  }

  @override
  void close({bool force = false}) {}
}

/// Records the order in which the sync steps run. An optional shared [log] lets
/// a test observe ordering across this and other spies (e.g. the wiper).
class _SpyRefresh implements CloudRefreshService {
  _SpyRefresh([this.log]);
  final List<String>? log;
  final calls = <String>[];
  @override
  Future<void> pushAll() async {
    calls.add('push');
    log?.add('push');
  }

  @override
  Future<void> pullAll() async {
    calls.add('pull');
    log?.add('pull');
  }
}

class _SpyWiper implements LocalDataWiper {
  _SpyWiper(this.log);
  final List<String> log;
  @override
  Future<void> wipe() async => log.add('wipe');
}

AuthApi _authApiWith(_AuthAdapter adapter, AuthTokenStore store) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter;
  final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter;
  return AuthApi(ApiClient(store, dio: dio, refreshDio: refreshDio));
}

void main() {
  late _MemTokenStore store;

  setUp(() {
    store = _MemTokenStore();
    if (sl.isRegistered<AuthTokenStore>()) sl.unregister<AuthTokenStore>();
    if (sl.isRegistered<AuthApi>()) sl.unregister<AuthApi>();
    sl.registerSingleton<AuthTokenStore>(store);
  });

  tearDown(() => sl.reset());

  test('starts signed out when no token stored', () {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(), store));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive
    expect(container.read(authSessionProvider).isSignedIn, isFalse);
  });

  test('signIn stores tokens and flips to signed in', () async {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(), store));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive

    final ok = await container.read(authSessionProvider.notifier).signIn('a@b.com', 'pw');

    expect(ok, isTrue);
    expect(container.read(authSessionProvider).isSignedIn, isTrue);
    expect(container.read(authSessionProvider).email, 'a@b.com');
    expect(store.accessToken, 'acc');
    expect(store.refreshToken, 'ref');
  });

  test('signIn failure sets an error and stays signed out', () async {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(loginSucceeds: false), store));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive

    final ok = await container.read(authSessionProvider.notifier).signIn('a@b.com', 'bad');

    expect(ok, isFalse);
    expect(container.read(authSessionProvider).isSignedIn, isFalse);
    expect(container.read(authSessionProvider).error, 'Bad email or password');
  });

  test('register then auto-login signs in', () async {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(), store));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive

    final ok = await container.read(authSessionProvider.notifier).register('a@b.com', 'password1');

    expect(ok, isTrue);
    expect(container.read(authSessionProvider).isSignedIn, isTrue);
  });

  test('signIn back-fills before pulling (push then pull)', () async {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(), store));
    final spy = _SpyRefresh();
    sl.registerSingleton<CloudRefreshService>(spy);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive

    await container.read(authSessionProvider.notifier).signIn('a@b.com', 'pw');

    expect(spy.calls, ['push', 'pull']);
  });

  test('signOut pushes local data up, then wipes it', () async {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(), store));
    final log = <String>[];
    sl.registerSingleton<CloudRefreshService>(_SpyRefresh(log));
    sl.registerSingleton<LocalDataWiper>(_SpyWiper(log));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive
    await container.read(authSessionProvider.notifier).signIn('a@b.com', 'pw');
    log.clear(); // drop the sign-in sync; we only care about sign-out

    await container.read(authSessionProvider.notifier).signOut();

    expect(log, ['push', 'wipe']); // saved to cloud before clearing
    expect(container.read(authSessionProvider).isSignedIn, isFalse);
  });

  test('signOut clears tokens and state', () async {
    sl.registerSingleton<AuthApi>(_authApiWith(_AuthAdapter(), store));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(authSessionProvider, (_, _) {}); // keep the notifier alive
    await container.read(authSessionProvider.notifier).signIn('a@b.com', 'pw');

    await container.read(authSessionProvider.notifier).signOut();

    expect(container.read(authSessionProvider).isSignedIn, isFalse);
    expect(store.accessToken, isNull);
  });
}
