import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/enum_x.dart';
import '../../../core/utils/finance_math.dart';
import '../domain/entities/lender.dart';

/// Drift row ↔ domain [Lender]. Text columns map to enums by name.
Lender lenderFromRow(LenderRow r) => Lender(
      id: r.id,
      name: r.name,
      type: enumByName(LenderType.values, r.type, LenderType.card),
      issuer: r.issuer,
      network: r.network,
      typicalRatePct: r.typicalRatePct,
      rateType: enumByName(RateType.values, r.rateType, RateType.reducing),
      feeType: enumByName(FeeType.values, r.feeType, FeeType.flat),
      feeValue: r.feeValue,
      feeCap: r.feeCap,
      isMine: r.isMine,
      notes: r.notes,
    );

LendersCompanion lenderToCompanion(Lender l) => LendersCompanion.insert(
      id: l.id,
      name: l.name,
      type: Value(l.type.name),
      issuer: Value(l.issuer),
      network: Value(l.network),
      typicalRatePct: Value(l.typicalRatePct),
      rateType: Value(l.rateType.name),
      feeType: Value(l.feeType.name),
      feeValue: Value(l.feeValue),
      feeCap: Value(l.feeCap),
      isMine: Value(l.isMine),
      notes: Value(l.notes),
    );
