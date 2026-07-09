import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Lenders: the catalog of banks / cards / BNPL apps. Seeded on first run and
/// user-editable. Enum-like fields (type, rateType, feeType) are stored as text
/// and mapped in the data layer.
@DataClassName('LenderRow')
class Lenders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('card'))();
  TextColumn get issuer => text().nullable()();
  TextColumn get network => text().nullable()();
  RealColumn get typicalRatePct => real().withDefault(const Constant(0))();
  TextColumn get rateType =>
      text().withDefault(const Constant('reducing'))();
  TextColumn get feeType => text().withDefault(const Constant('flat'))();
  RealColumn get feeValue => real().withDefault(const Constant(0))();
  RealColumn get feeCap => real().nullable()();
  RealColumn get feeMin => real().nullable()();
  BoolColumn get isMine => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Borrowings: each loan / BNPL draw / card advance the user wants to track.
/// Columns are primitive on purpose — domain enums (status, rate type) are
/// stored as text and mapped in the data layer, keeping the DB decoupled.
@DataClassName('BorrowingRow')
class Borrowings extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind =>
      text().withDefault(const Constant('flexibleLoan'))();
  TextColumn get lenderId => text().nullable()();
  TextColumn get lenderName => text()();
  RealColumn get principal => real()();
  RealColumn get processingFee => real().withDefault(const Constant(0))();
  RealColumn get gstOnFee => real().withDefault(const Constant(0))();
  RealColumn get foreclosureFee => real().nullable()();
  BoolColumn get gstOnInterest =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isNoCostEmi => boolean().withDefault(const Constant(false))();
  BoolColumn get feeFinanced => boolean().withDefault(const Constant(false))();
  RealColumn get interestRatePct => real().withDefault(const Constant(0))();
  TextColumn get rateType =>
      text().withDefault(const Constant('reducing'))();
  IntColumn get tenureMonths => integer().withDefault(const Constant(0))();
  RealColumn get minPayment => real().withDefault(const Constant(0))();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Repayments: the ledger entries against a borrowing.
@DataClassName('RepaymentRow')
class Repayments extends Table {
  TextColumn get id => text()();
  TextColumn get borrowingId =>
      text().references(Borrowings, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  IntColumn get installmentNo => integer().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Recurring obligations: subscriptions, bills, and EMI schedules.
@DataClassName('RecurringItemRow')
class RecurringItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text().withDefault(const Constant('subscription'))();
  RealColumn get amount => real()();
  TextColumn get frequency => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get nextDueDate => dateTime()();
  TextColumn get category => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Credit cards the user manages: each references a lender-catalog entry (the
/// user's own cards) and adds the billing cycle — statement-level tracking,
/// never transaction-level.
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get lenderId => text()();

  /// Day of month the statement is generated (1–31, clamped to month end).
  IntColumn get statementDay => integer()();

  /// Day of month the bill is due (1–31, clamped).
  IntColumn get dueDay => integer()();
  RealColumn get creditLimit => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One monthly card statement: the single entered number (the bill total)
/// plus its due/paid state. The EMI portion is derived, never stored.
@DataClassName('CardStatementRow')
class CardStatements extends Table {
  TextColumn get id => text()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();

  /// First day of the month the statement was generated in.
  DateTimeColumn get cycleMonth => dateTime()();
  RealColumn get statementAmount => real()();
  DateTimeColumn get dueDate => dateTime()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get paidDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {cardId, cycleMonth},
      ];
}

/// The single local database shared across features.
@DriftDatabase(
  tables: [Lenders, Borrowings, Repayments, RecurringItems, Cards, CardStatements],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(recurringItems);
          if (from < 3) await m.addColumn(lenders, lenders.feeCap);
          if (from < 4) {
            await m.addColumn(borrowings, borrowings.kind);
            await m.addColumn(borrowings, borrowings.gstOnInterest);
            await m.addColumn(borrowings, borrowings.minPayment);
            await m.addColumn(repayments, repayments.installmentNo);
            // Existing borrowings with a tenure were structured EMIs.
            await customStatement(
              "UPDATE borrowings SET kind = 'fixedEmi' WHERE tenure_months > 0",
            );
          }
          if (from < 5) {
            await m.addColumn(borrowings, borrowings.foreclosureFee);
          }
          if (from < 6) {
            await m.createTable(cards);
            await m.createTable(cardStatements);
          }
          if (from < 7) {
            await m.addColumn(borrowings, borrowings.isNoCostEmi);
            await m.addColumn(borrowings, borrowings.feeFinanced);
            await m.addColumn(lenders, lenders.feeMin);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _open() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/recurring.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
