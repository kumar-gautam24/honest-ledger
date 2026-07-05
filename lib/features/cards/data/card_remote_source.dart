import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/money_json.dart';
import '../../../core/api/paginated.dart';
import '../domain/entities/card_account.dart';
import '../domain/entities/card_statement.dart';

/// Talks to `/v1/cards` and `/v1/statements`. The card's display `name` is
/// resolved from the lender catalog client-side, so it is neither sent nor stored.
abstract interface class CardRemoteSource {
  Future<List<CardAccount>> fetchCards();
  Future<List<CardStatement>> fetchStatements(String cardId);
  Future<void> pushCard(CardAccount card);
  Future<void> deleteCard(String id);
  Future<void> pushStatement(CardStatement statement);
  Future<void> deleteStatement(String id);
}

class CardRemoteSourceDio implements CardRemoteSource {
  CardRemoteSourceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  @override
  Future<List<CardAccount>> fetchCards() =>
      fetchAllPages((cursor) => _page('/v1/cards', cursor), cardFromJson);

  @override
  Future<List<CardStatement>> fetchStatements(String cardId) => fetchAllPages(
        (cursor) => _page('/v1/cards/$cardId/statements', cursor),
        statementFromJson,
      );

  Future<Map<String, dynamic>> _page(String path, int cursor) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: {'cursor': cursor, 'limit': 200},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> pushCard(CardAccount c) async {
    final now = DateTime.now().toUtc();
    try {
      await _dio.patch<dynamic>(
        '/v1/cards/${c.id}',
        data: {...cardFields(c), 'updated_at': formatApiDate(now)},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post<dynamic>('/v1/cards', data: cardToJson(c));
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteCard(String id) async {
    await _dio.delete<dynamic>('/v1/cards/$id');
  }

  @override
  Future<void> pushStatement(CardStatement s) async {
    final now = DateTime.now().toUtc();
    try {
      await _dio.patch<dynamic>(
        '/v1/statements/${s.id}',
        data: {...statementFields(s), 'updated_at': formatApiDate(now)},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post<dynamic>('/v1/cards/${s.cardId}/statements',
            data: statementToJson(s));
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteStatement(String id) async {
    await _dio.delete<dynamic>('/v1/statements/$id');
  }
}

// ---- Mapping ----

Map<String, dynamic> cardFields(CardAccount c) => {
      'lender_id': c.lenderId,
      'statement_day': c.statementDay,
      'due_day': c.dueDay,
      'credit_limit_paise':
          c.creditLimit == null ? null : rupeesToPaise(c.creditLimit!),
      'is_active': c.isActive,
    };

Map<String, dynamic> cardToJson(CardAccount c) => {
      'id': c.id,
      ...cardFields(c),
      'created_at': formatApiDate(c.createdAt),
    };

CardAccount cardFromJson(Map<String, dynamic> j) => CardAccount(
      id: j['id'] as String,
      lenderId: j['lender_id'] as String,
      // Display name is resolved from the catalog on read; not persisted.
      name: '',
      statementDay: j['statement_day'] as int,
      dueDay: j['due_day'] as int,
      creditLimit: j['credit_limit_paise'] == null
          ? null
          : paiseToRupees(j['credit_limit_paise'] as int),
      isActive: (j['is_active'] as bool?) ?? true,
      createdAt: parseApiDate(j['created_at'] as String),
    );

Map<String, dynamic> statementFields(CardStatement s) => {
      'cycle_month': formatApiDate(s.cycleMonth),
      'statement_amount_paise': rupeesToPaise(s.statementAmount),
      'due_date': formatApiDate(s.dueDate),
      'paid_amount_paise': rupeesToPaise(s.paidAmount),
      'paid_date': s.paidDate == null ? null : formatApiDate(s.paidDate!),
      'notes': s.notes,
    };

Map<String, dynamic> statementToJson(CardStatement s) => {
      'id': s.id,
      ...statementFields(s),
    };

CardStatement statementFromJson(Map<String, dynamic> j) => CardStatement(
      id: j['id'] as String,
      cardId: j['card_id'] as String,
      cycleMonth: parseApiDate(j['cycle_month'] as String),
      statementAmount: paiseToRupees(j['statement_amount_paise'] as int),
      dueDate: parseApiDate(j['due_date'] as String),
      paidAmount: paiseToRupees((j['paid_amount_paise'] as int?) ?? 0),
      paidDate:
          j['paid_date'] == null ? null : parseApiDate(j['paid_date'] as String),
      notes: j['notes'] as String?,
    );
