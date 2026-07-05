import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/api_client.dart';
import 'package:recurring/core/api/auth_token_store.dart';
import 'package:recurring/features/money_leak/data/borrowing_remote_source.dart';

class _Tokens implements AuthTokenStore {
  @override
  String? get accessToken => 'a';
  @override
  String? get refreshToken => 'r';
  @override
  String? get email => 'a@b.com';
  @override
  bool get isSignedIn => true;
  @override
  Future<void> save({required String accessToken, required String refreshToken, required String email}) async {}
  @override
  Future<void> updateAccessToken(String accessToken) async {}
  @override
  Future<void> clear() async {}
}

Map<String, dynamic> _borrowing(String id) => {
      'id': id,
      'title': 't',
      'kind': 'fixedEmi',
      'lender_name': 'x',
      'principal_paise': 1000,
      'start_date': '2026-01-01',
      'created_at': '2026-01-01',
      'status': 'active',
    };

/// Serves `/v1/borrowings` as two pages keyed off the `cursor` query param.
class _PagedAdapter implements HttpClientAdapter {
  final seenCursors = <String>[];

  ResponseBody _json(Map<String, dynamic> body) =>
      ResponseBody.fromString(jsonEncode(body), 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? s,
      Future<void>? c) async {
    final cursor = options.uri.queryParameters['cursor'] ?? '0';
    seenCursors.add(cursor);
    if (cursor == '0') {
      return _json({
        'items': [_borrowing('b1'), _borrowing('b2')],
        'next_cursor': 2,
        'has_more': true,
      });
    }
    return _json({
      'items': [_borrowing('b3')],
      'next_cursor': 3,
      'has_more': false,
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('fetchBorrowings drains past the first page', () async {
    final adapter = _PagedAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter;
    final client = ApiClient(_Tokens(), dio: dio, refreshDio: dio);
    final source = BorrowingRemoteSourceDio(client);

    final borrowings = await source.fetchBorrowings();

    expect(borrowings.map((b) => b.id), ['b1', 'b2', 'b3']);
    expect(adapter.seenCursors, ['0', '2']); // followed the cursor
  });
}
