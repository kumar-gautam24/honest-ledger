import '../../../recurring/domain/entities/recurring_item.dart';

/// The kind of obligation a row represents — the axis the home filter and the
/// monthly roll-ups slice on.
enum ObligationCategory { emi, loan, subscription, bill, card }

extension RecurringTypeCategory on RecurringType {
  /// Legacy EMIs recorded as recurring items count as bills; new EMIs are
  /// borrowings.
  ObligationCategory get obligationCategory => switch (this) {
        RecurringType.subscription => ObligationCategory.subscription,
        RecurringType.bill || RecurringType.emi => ObligationCategory.bill,
      };
}
