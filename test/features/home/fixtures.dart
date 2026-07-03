import 'package:recurring/core/utils/finance_math.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing_summary.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';

/// A fixed-EMI borrowing summary with [paidInstallments] ticked off.
BorrowingSummary emiSummary({
  String id = 'emi-1',
  String title = 'Phone EMI',
  double principal = 12000,
  double ratePct = 0,
  int months = 12,
  required DateTime startDate,
  int paidInstallments = 0,
  BorrowingStatus status = BorrowingStatus.active,
  String? lenderId,
}) {
  final b = Borrowing(
    id: id,
    title: title,
    lenderId: lenderId,
    lenderName: 'Test Bank',
    principal: principal,
    startDate: startDate,
    createdAt: startDate,
    kind: BorrowingKind.fixedEmi,
    interestRatePct: ratePct,
    rateType: RateType.reducing,
    tenureMonths: months,
    status: status,
  );
  final schedule = FinanceMath.emiSchedule(
    principal: principal,
    annualRatePct: ratePct,
    months: months,
    startDate: startDate,
  );
  final repayments = [
    for (var n = 1; n <= paidInstallments; n++)
      Repayment(
        id: '$id-r$n',
        borrowingId: id,
        amount: schedule[n - 1].total,
        date: schedule[n - 1].dueDate,
        installmentNo: n,
      ),
  ];
  return BorrowingSummary.from(b, repayments);
}

/// A flexible-loan borrowing summary with free-form [repayments].
BorrowingSummary loanSummary({
  String id = 'loan-1',
  String title = 'Quick loan',
  double principal = 10000,
  double ratePct = 30,
  double minPayment = 2000,
  required DateTime startDate,
  List<Repayment> repayments = const [],
  BorrowingStatus status = BorrowingStatus.active,
}) {
  final b = Borrowing(
    id: id,
    title: title,
    lenderName: 'Test App',
    principal: principal,
    startDate: startDate,
    createdAt: startDate,
    interestRatePct: ratePct,
    minPayment: minPayment,
    status: status,
  );
  return BorrowingSummary.from(b, repayments);
}

RecurringItem recurringItem({
  String id = 'rec-1',
  String title = 'Sub',
  double amount = 499,
  RecurringType type = RecurringType.subscription,
  Frequency frequency = Frequency.monthly,
  required DateTime nextDueDate,
  DateTime? createdAt,
  bool isActive = true,
}) {
  return RecurringItem(
    id: id,
    title: title,
    amount: amount,
    type: type,
    frequency: frequency,
    nextDueDate: nextDueDate,
    isActive: isActive,
    createdAt: createdAt ?? nextDueDate.subtract(const Duration(days: 365)),
  );
}
