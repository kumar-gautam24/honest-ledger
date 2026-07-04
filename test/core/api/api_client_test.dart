import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/api_client.dart';
import 'package:recurring/core/api/auth_token_store.dart';

/// An in-memory token store so tests don't need SharedPreferences.
class _FakeTokenStore implements AuthTokenStore {
  _FakeTokenStore({this.access, this.refresh, this.mail});
  String? access;
  String? refresh;
  String? mail;

  @override
  String? get accessToken => access;
  @override
  String? get refreshToken => refresh;
  @override
  String? get email => mail;
  @override
  bool get isSignedIn => access != null && access!.isNotEmpty;
  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    access = accessToken;
    refresh = refreshToken;
    mail = email;
  }

  @override
  Future<void> updateAccessToken(String accessToken) async {
    access = accessToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    mail = null;
  }
}

/// A scripted HTTP adapter. Routes by path; the protected path returns 401 until
/// [protectedUnlocked] flips true (simulating a refreshed token being accepted).
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter({required this.refreshSucceeds});

  final bool refreshSucceeds;
  bool protectedUnlocked = false;
  final List<String> seenAuthHeaders = [];

  ResponseBody _json(Map<String, dynamic> body, int status) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/v1/auth/refresh') {
      if (!refreshSucceeds) return _json({'error': 'nope'}, 401);
      protectedUnlocked = true;
      return _json(
        {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
        200,
      );
    }
    // A protected resource path.
    seenAuthHeaders.add(options.headers['Authorization']?.toString() ?? '');
    if (protectedUnlocked) return _json({'ok': true}, 200);
    return _json({'error': 'unauthorized'}, 401);
  }

  @override
  void close({bool force = false}) {}
}

ApiClient _client(_FakeTokenStore store, _ScriptedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  final refreshDio = Dio(BaseOptions(baseUrl: 'http://test'))
    ..httpClientAdapter = adapter;
  return ApiClient(store, dio: dio, refreshDio: refreshDio);
}

void main() {
  test('attaches bearer token to requests when signed in', () async {
    final store = _FakeTokenStore(access: 'access-1', refresh: 'r', mail: 'a@b.com');
    final adapter = _ScriptedAdapter(refreshSucceeds: true)..protectedUnlocked = true;
    final client = _client(store, adapter);

    await client.dio.get<dynamic>('/v1/borrowings');

    expect(adapter.seenAuthHeaders.first, 'Bearer access-1');
  });

  test('on 401, refreshes once and retries with the new token', () async {
    final store =
        _FakeTokenStore(access: 'access-1', refresh: 'refresh-1', mail: 'a@b.com');
    final adapter = _ScriptedAdapter(refreshSucceeds: true);
    final client = _client(store, adapter);

    final response = await client.dio.get<dynamic>('/v1/borrowings');

    expect(response.statusCode, 200);
    expect(store.accessToken, 'access-2'); // rotated
    expect(store.refreshToken, 'refresh-2');
    // First attempt used the old token; the retry used the refreshed one.
    expect(adapter.seenAuthHeaders, ['Bearer access-1', 'Bearer access-2']);
  });

  test('when refresh fails, tokens are cleared and the error surfaces', () async {
    final store =
        _FakeTokenStore(access: 'access-1', refresh: 'refresh-1', mail: 'a@b.com');
    final adapter = _ScriptedAdapter(refreshSucceeds: false);
    final client = _client(store, adapter);

    await expectLater(
      client.dio.get<dynamic>('/v1/borrowings'),
      throwsA(isA<DioException>()),
    );
    expect(store.isSignedIn, isFalse);
  });
}
