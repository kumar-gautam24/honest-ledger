import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/money_json.dart';
import '../../../core/api/paginated.dart';
import '../../../core/utils/finance_math.dart';
import '../domain/entities/borrowing.dart';
import '../domain/entities/repayment.dart';

/// Talks to `/v1/borrowings` and `/v1/repayments`. Maps between the domain
/// entities (rupees, enums) and the API JSON (integer paise, text). Interface
/// first so the composite repository can be tested with a fake.
abstract interface class BorrowingRemoteSource {
  Future<List<Borrowing>> fetchBorrowings();
  Future<List<Repayment>> fetchRepayments(String borrowingId);
  Future<void> pushBorrowing(Borrowing borrowing);
  Future<void> deleteBorrowing(String id);
  Future<void> pushRepayment(Repayment repayment);
  Future<void> deleteRepayment(String id);
}

class BorrowingRemoteSourceDio implements BorrowingRemoteSource {
  BorrowingRemoteSourceDio(this._client);

  final ApiClient _client;
  Dio get _dio => _client.dio;

  @override
  Future<List<Borrowing>> fetchBorrowings() => fetchAllPages(
        (cursor) => _page('/v1/borrowings', cursor),
        borrowingFromJson,
      );

  @override
  Future<List<Repayment>> fetchRepayments(String borrowingId) => fetchAllPages(
        (cursor) => _page('/v1/borrowings/$borrowingId/repayments', cursor),
        repaymentFromJson,
      );

  Future<Map<String, dynamic>> _page(String path, int cursor) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: {'cursor': cursor, 'limit': 200},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> pushBorrowing(Borrowing b) async {
    // Client is authoritative (no sync): PATCH the existing row with a fresh
    // timestamp; if it doesn't exist yet (404), create it. Best-effort — the
    // caller swallows failures and relies on the local cache.
    final now = DateTime.now().toUtc();
    try {
      await _dio.patch<dynamic>(
        '/v1/borrowings/${b.id}',
        data: {...borrowingFields(b), 'updated_at': formatApiDate(now)},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post<dynamic>('/v1/borrowings', data: borrowingToJson(b));
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteBorrowing(String id) async {
    await _dio.delete<dynamic>('/v1/borrowings/$id');
  }

  @override
  Future<void> pushRepayment(Repayment r) async {
    final now = DateTime.now().toUtc();
    try {
      await _dio.patch<dynamic>(
        '/v1/repayments/${r.id}',
        data: {...repaymentFields(r), 'updated_at': formatApiDate(now)},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _dio.post<dynamic>(
          '/v1/borrowings/${r.borrowingId}/repayments',
          data: repaymentToJson(r),
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteRepayment(String id) async {
    await _dio.delete<dynamic>('/v1/repayments/$id');
  }
}

// ---- Mapping (pure functions, unit-tested) ----

/// The mutable fields of a borrowing, shared by create and update payloads.
Map<String, dynamic> borrowingFields(Borrowing b) => {
      'title': b.title,
      'kind': b.kind.name,
      'lender_id': b.lenderId,
      'lender_name': b.lenderName,
      'principal_paise': rupeesToPaise(b.principal),
      'processing_fee_paise': rupeesToPaise(b.processingFee),
      'gst_on_fee_paise': rupeesToPaise(b.gstOnFee),
      'foreclosure_fee_paise': rupeesToPaise(b.foreclosureFee),
      'gst_on_interest': b.gstOnInterest,
      'is_no_cost_emi': b.isNoCostEmi,
      'fee_financed': b.feeFinanced,
      'interest_rate_pct': b.interestRatePct,
      'rate_type': b.rateType.name,
      'tenure_months': b.tenureMonths,
      'min_payment_paise': rupeesToPaise(b.minPayment),
      'day_count': b.dayCount.name,
      'first_due_date':
          b.firstDueDate == null ? null : formatApiDate(b.firstDueDate!),
      'first_period_days': b.firstPeriodDays,
      'start_date': formatApiDate(b.startDate),
      'status': b.status.name,
      'notes': b.notes,
    };

Map<String, dynamic> borrowingToJson(Borrowing b) => {
      'id': b.id,
      ...borrowingFields(b),
      'created_at': formatApiDate(b.createdAt),
    };

Borrowing borrowingFromJson(Map<String, dynamic> j) => Borrowing(
      id: j['id'] as String,
      title: j['title'] as String,
      kind: _enumByName(BorrowingKind.values, j['kind'], BorrowingKind.flexibleLoan),
      lenderId: j['lender_id'] as String?,
      lenderName: (j['lender_name'] as String?) ?? '',
      principal: paiseToRupees(j['principal_paise'] as int),
      processingFee: paiseToRupees((j['processing_fee_paise'] as int?) ?? 0),
      gstOnFee: paiseToRupees((j['gst_on_fee_paise'] as int?) ?? 0),
      foreclosureFee: paiseToRupees((j['foreclosure_fee_paise'] as int?) ?? 0),
      gstOnInterest: (j['gst_on_interest'] as bool?) ?? false,
      isNoCostEmi: (j['is_no_cost_emi'] as bool?) ?? false,
      feeFinanced: (j['fee_financed'] as bool?) ?? false,
      interestRatePct: ((j['interest_rate_pct'] as num?) ?? 0).toDouble(),
      rateType: _enumByName(RateType.values, j['rate_type'], RateType.reducing),
      tenureMonths: (j['tenure_months'] as int?) ?? 0,
      minPayment: paiseToRupees((j['min_payment_paise'] as int?) ?? 0),
      dayCount: _enumByName(
        DayCountConvention.values,
        j['day_count'],
        DayCountConvention.monthlyUniform,
      ),
      firstDueDate: j['first_due_date'] == null
          ? null
          : parseApiDate(j['first_due_date'] as String),
      firstPeriodDays: j['first_period_days'] as int?,
      startDate: parseApiDate(j['start_date'] as String),
      status: _enumByName(BorrowingStatus.values, j['status'], BorrowingStatus.active),
      notes: j['notes'] as String?,
      createdAt: parseApiDate(j['created_at'] as String),
    );

Map<String, dynamic> repaymentFields(Repayment r) => {
      'amount_paise': rupeesToPaise(r.amount),
      'date': formatApiDate(r.date),
      'kind': r.kind.name,
      'installment_no': r.installmentNo,
      'note': r.note,
    };

Map<String, dynamic> repaymentToJson(Repayment r) => {
      'id': r.id,
      ...repaymentFields(r),
    };

Repayment repaymentFromJson(Map<String, dynamic> j) => Repayment(
      id: j['id'] as String,
      borrowingId: j['borrowing_id'] as String,
      amount: paiseToRupees(j['amount_paise'] as int),
      date: parseApiDate(j['date'] as String),
      kind: _enumByName(RepaymentKind.values, j['kind'], RepaymentKind.payment),
      installmentNo: j['installment_no'] as int?,
      note: j['note'] as String?,
    );

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
