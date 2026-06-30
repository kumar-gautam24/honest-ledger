import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/enum_x.dart';
import '../../../core/utils/finance_math.dart';
import '../domain/entities/borrowing.dart';
import '../domain/entities/repayment.dart';

Borrowing borrowingFromRow(BorrowingRow r) => Borrowing(
      id: r.id,
      title: r.title,
      lenderId: r.lenderId,
      lenderName: r.lenderName,
      principal: r.principal,
      processingFee: r.processingFee,
      gstOnFee: r.gstOnFee,
      interestRatePct: r.interestRatePct,
      rateType: enumByName(RateType.values, r.rateType, RateType.reducing),
      tenureMonths: r.tenureMonths,
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
      lenderId: Value(b.lenderId),
      processingFee: Value(b.processingFee),
      gstOnFee: Value(b.gstOnFee),
      interestRatePct: Value(b.interestRatePct),
      rateType: Value(b.rateType.name),
      tenureMonths: Value(b.tenureMonths),
      status: Value(b.status.name),
      notes: Value(b.notes),
    );

Repayment repaymentFromRow(RepaymentRow r) => Repayment(
      id: r.id,
      borrowingId: r.borrowingId,
      amount: r.amount,
      date: r.date,
      note: r.note,
    );

RepaymentsCompanion repaymentToCompanion(Repayment r) =>
    RepaymentsCompanion.insert(
      id: r.id,
      borrowingId: r.borrowingId,
      amount: r.amount,
      date: r.date,
      note: Value(r.note),
    );
