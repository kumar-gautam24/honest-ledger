import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/api_client.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/features/settings/data/settings_remote_source.dart';
import 'package:recurring/features/settings/presentation/controllers/income_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Tokens implements AuthTokenStore {
  bool signedIn = true;
  @override
  bool get isSignedIn => signedIn;
  @override
  String? get accessToken => signedIn ? 'a' : null;
  @override
  String? get refreshToken => signedIn ? 'r' : null;
  @override
  String? get email => null;
  @override
  Future<void> save({required String accessToken, required String refreshToken, required String email}) async {}
  @override
  Future<void> updateAccessToken(String accessToken) async {}
  @override
  Future<void> clear() async {}
}

class _FakeSettingsRemote implements SettingsRemoteSource {
  double? pushed;
  bool cleared = false;
  double? toReturn;
  @override
  Future<double?> fetchIncome() async => toReturn;
  @override
  Future<void> pushIncome(double rupees) async => pushed = rupees;
  @override
  Future<void> clearIncome() async => cleared = true;
}

class _SettingsAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastPutBody;

  ResponseBody _json(Map<String, dynamic> body, int status) =>
      ResponseBody.fromString(jsonEncode(body), status, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? s,
      Future<void>? c) async {
    if (options.method == 'GET' && options.path == '/v1/settings') {
      return _json({
        'items': [
          {'key': 'income', 'value': 5000000, 'updated_at': '2026-07-01T00:00:00Z', 'deleted_at': null, 'server_seq': 1},
        ],
      }, 200);
    }
    if (options.method == 'PUT') {
      lastPutBody = options.data as Map<String, dynamic>;
      return _json({'key': 'income', 'value': lastPutBody!['value'], 'updated_at': '2026-07-01T00:00:00Z', 'deleted_at': null, 'server_seq': 2}, 200);
    }
    return _json({}, 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsRemoteSourceDio', () {
    test('fetchIncome parses paise into rupees', () async {
      final adapter = _SettingsAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter;
      final source = SettingsRemoteSourceDio(ApiClient(_Tokens(), dio: dio, refreshDio: dio));
      expect(await source.fetchIncome(), 50000.0);
    });

    test('pushIncome sends paise', () async {
      final adapter = _SettingsAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'http://test'))..httpClientAdapter = adapter;
      final source = SettingsRemoteSourceDio(ApiClient(_Tokens(), dio: dio, refreshDio: dio));
      await source.pushIncome(50000.0);
      expect(adapter.lastPutBody!['value'], 5000000);
    });
  });

  group('IncomeController sync', () {
    late _FakeSettingsRemote remote;
    late _Tokens tokens;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      remote = _FakeSettingsRemote();
      tokens = _Tokens();
      await sl.reset();
      sl.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
      sl.registerSingleton<AuthTokenStore>(tokens);
      sl.registerSingleton<SettingsRemoteSource>(remote);
    });
    tearDown(() => sl.reset());

    test('signed in: setting income pushes to the backend', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(incomeControllerProvider, (_, _) {});

      await container.read(incomeControllerProvider.notifier).set(50000);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(incomeControllerProvider), 50000);
      expect(remote.pushed, 50000);
    });

    test('signed out: setting income does not push', () async {
      tokens.signedIn = false;
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(incomeControllerProvider, (_, _) {});

      await container.read(incomeControllerProvider.notifier).set(50000);
      await Future<void>.delayed(Duration.zero);

      expect(remote.pushed, isNull);
    });

    test('clearing income calls clearIncome when signed in', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(incomeControllerProvider, (_, _) {});

      await container.read(incomeControllerProvider.notifier).set(null);
      await Future<void>.delayed(Duration.zero);

      expect(remote.cleared, isTrue);
    });
  });
}
