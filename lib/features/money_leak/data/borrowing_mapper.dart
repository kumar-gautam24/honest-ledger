import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/enum_x.dart';
import '../../../core/utils/finance_math.dart';
import '../domain/entities/borrowing.dart';
import '../domain/entities/repayment.dart';

Borrowing borrowingFromRow(BorrowingRow r) => Borrowing(
      id: r.id,
      title: r.title,
      kind: enumByName(BorrowingKind.values, r.kind, BorrowingKind.flexibleLoan),
      lenderId: r.lenderId,
      lenderName: r.lenderName,
      principal: r.principal,
      processingFee: r.processingFee,
      gstOnFee: r.gstOnFee,
      foreclosureFee: r.foreclosureFee ?? 0,
      gstOnInterest: r.gstOnInterest,
      interestRatePct: r.interestRatePct,
      rateType: enumByName(RateType.values, r.rateType, RateType.reducing),
      tenureMonths: r.tenureMonths,
      minPayment: r.minPayment,
      startDate: r.startDate,
      status: enumByName(BorrowingStatus.values, r.status, BorrowingStatus.active),
      notes: r.notes,
      createdAt: r.createdAt,
    );

BorrowingsCompanion borrowingToCompanion(Borrowing b) =>
    BorrowingsCompanion.insert(
      id: b.id,
      title: b.title,
      lenderName: b.lenderName,
      principal: b.principal,
      startDate: b.startDate,
      createdAt: b.createdAt,
      kind: Value(b.kind.name),
      lenderId: Value(b.lenderId),
      processingFee: Value(b.processingFee),
      gstOnFee: Value(b.gstOnFee),
      foreclosureFee: Value(b.foreclosureFee),
      gstOnInterest: Value(b.gstOnInterest),
      interestRatePct: Value(b.interestRatePct),
      rateType: Value(b.rateType.name),
      tenureMonths: Value(b.tenureMonths),
      minPayment: Value(b.minPayment),
      status: Value(b.status.name),
      notes: Value(b.notes),
    );

Repayment repaymentFromRow(RepaymentRow r) => Repayment(
      id: r.id,
      borrowingId: r.borrowingId,
      amount: r.amount,
      date: r.date,
      installmentNo: r.installmentNo,
      note: r.note,
    );

RepaymentsCompanion repaymentToCompanion(Repayment r) =>
    RepaymentsCompanion.insert(
      id: r.id,
      borrowingId: r.borrowingId,
      amount: r.amount,
      date: r.date,
      installmentNo: Value(r.installmentNo),
      note: Value(r.note),
    );
