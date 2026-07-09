import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/money_json.dart';
import '../../../core/api/paginated.dart';
import '../../../core/utils/finance_math.dart';
import '../domain/entities/lender.dart';

/// Talks to `/v1/lenders` — the per-user CUSTOM lender store. Built-in catalog
/// entries are not sent here; the composite filters them out. Rate/fee fields are
/// calculator config (percent / flat), so they stay as-is, not paise.
abstract interface class LenderRemoteSource {
  Future<List<Lender>> fetchAll();
  Future<void> push(Lender lender);
  Future<void> delete(String id);
}

class LenderRemoteSourceDio implements LenderRemoteSource {
  LenderRemoteSourceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  @override
  Future<List<Lender>> fetchAll() async {
    return fetchAllPages((cursor) async {
      final response = await _dio.get<dynamic>(
        '/v1/lenders',
        queryParameters: {'cursor': cursor, 'limit': 200},
      );
      return response.data as Map<String, dynamic>;
    }, lenderFromJson);
  }

  @override
  Future<void> push(Lender lender) async {
    final now = DateTime.now().toUtc();
    try {
      await _dio.patch<dynamic>(
        '/v1/lenders/${lender.id}',
        data: {...lenderFields(lender), 'updated_at': formatApiDate(now)},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post<dynamic>('/v1/lenders', data: lenderToJson(lender));
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete<dynamic>('/v1/lenders/$id');
  }
}

// ---- Mapping ----

Map<String, dynamic> lenderFields(Lender l) => {
      'name': l.name,
      'type': l.type.name,
      'issuer': l.issuer,
      'network': l.network,
      'typical_rate_pct': l.typicalRatePct,
      'rate_type': l.rateType.name,
      'fee_type': l.feeType.name,
      'fee_value': l.feeValue,
      'fee_cap': l.feeCap,
      'fee_min': l.feeMin,
      'is_mine': l.isMine,
      'notes': l.notes,
    };

Map<String, dynamic> lenderToJson(Lender l) => {'id': l.id, ...lenderFields(l)};

Lender lenderFromJson(Map<String, dynamic> j) => Lender(
      id: j['id'] as String,
      name: j['name'] as String,
      type: _enumByName(LenderType.values, j['type'], LenderType.card),
      issuer: j['issuer'] as String?,
      network: j['network'] as String?,
      typicalRatePct: ((j['typical_rate_pct'] as num?) ?? 0).toDouble(),
      rateType: _enumByName(RateType.values, j['rate_type'], RateType.reducing),
      feeType: _enumByName(FeeType.values, j['fee_type'], FeeType.flat),
      feeValue: ((j['fee_value'] as num?) ?? 0).toDouble(),
      feeCap: (j['fee_cap'] as num?)?.toDouble(),
      feeMin: (j['fee_min'] as num?)?.toDouble(),
      isMine: (j['is_mine'] as bool?) ?? false,
      notes: j['notes'] as String?,
    );

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
