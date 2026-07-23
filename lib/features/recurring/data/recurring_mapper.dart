import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/enum_x.dart';
import '../domain/entities/recurring_item.dart';

RecurringItem recurringFromRow(RecurringItemRow r) => RecurringItem(
      id: r.id,
      title: r.title,
      type: enumByName(RecurringType.values, r.type, RecurringType.subscription),
      amount: r.amount,
      frequency: enumByName(Frequency.values, r.frequency, Frequency.monthly),
      nextDueDate: r.nextDueDate,
      category: r.category,
      cardId: r.cardId,
      isActive: r.isActive,
      notes: r.notes,
      createdAt: r.createdAt,
    );

RecurringItemsCompanion recurringToCompanion(RecurringItem i) =>
    RecurringItemsCompanion.insert(
      id: i.id,
      title: i.title,
      amount: i.amount,
      nextDueDate: i.nextDueDate,
      createdAt: i.createdAt,
      type: Value(i.type.name),
      frequency: Value(i.frequency.name),
      category: Value(i.category),
      cardId: Value(i.cardId),
      isActive: Value(i.isActive),
      notes: Value(i.notes),
    );
