import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/money_json.dart';
import '../../../core/api/paginated.dart';
import '../domain/entities/recurring_item.dart';

/// Talks to `/v1/recurring-items`. Maps entity (rupees, enums) <-> JSON (paise).
abstract interface class RecurringRemoteSource {
  Future<List<RecurringItem>> fetchAll();
  Future<void> push(RecurringItem item);
  Future<void> delete(String id);
}

class RecurringRemoteSourceDio implements RecurringRemoteSource {
  RecurringRemoteSourceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  @override
  Future<List<RecurringItem>> fetchAll() async {
    return fetchAllPages((cursor) async {
      final response = await _dio.get<dynamic>(
        '/v1/recurring-items',
        queryParameters: {'cursor': cursor, 'limit': 200},
      );
      return response.data as Map<String, dynamic>;
    }, recurringFromJson);
  }

  @override
  Future<void> push(RecurringItem item) async {
    final now = DateTime.now().toUtc();
    try {
      await _dio.patch<dynamic>(
        '/v1/recurring-items/${item.id}',
        data: {...recurringFields(item), 'updated_at': formatApiDate(now)},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post<dynamic>('/v1/recurring-items',
            data: recurringToJson(item));
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<dynamic>('/v1/recurring-items/$id');
  }
}

// ---- Mapping ----

Map<String, dynamic> recurringFields(RecurringItem i) => {
      'title': i.title,
      'type': i.type.name,
      'amount_paise': rupeesToPaise(i.amount),
      'frequency': i.frequency.name,
      'next_due_date': formatApiDate(i.nextDueDate),
      'category': i.category,
      'is_active': i.isActive,
      'notes': i.notes,
    };

Map<String, dynamic> recurringToJson(RecurringItem i) => {
      'id': i.id,
      ...recurringFields(i),
      'created_at': formatApiDate(i.createdAt),
    };

RecurringItem recurringFromJson(Map<String, dynamic> j) => RecurringItem(
      id: j['id'] as String,
      title: j['title'] as String,
      type: _enumByName(RecurringType.values, j['type'], RecurringType.subscription),
      amount: paiseToRupees(j['amount_paise'] as int),
      frequency: _enumByName(Frequency.values, j['frequency'], Frequency.monthly),
      nextDueDate: parseApiDate(j['next_due_date'] as String),
      category: j['category'] as String?,
      isActive: (j['is_active'] as bool?) ?? true,
      notes: j['notes'] as String?,
      createdAt: parseApiDate(j['created_at'] as String),
    );

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
