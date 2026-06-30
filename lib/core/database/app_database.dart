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
  TextColumn get lenderId => text().nullable()();
  TextColumn get lenderName => text()();
  RealColumn get principal => real()();
  RealColumn get processingFee => real().withDefault(const Constant(0))();
  RealColumn get gstOnFee => real().withDefault(const Constant(0))();
  RealColumn get interestRatePct => real().withDefault(const Constant(0))();
  TextColumn get rateType =>
      text().withDefault(const Constant('reducing'))();
  IntColumn get tenureMonths => integer().withDefault(const Constant(0))();
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

/// The single local database shared across features.
@DriftDatabase(tables: [Lenders, Borrowings, Repayments, RecurringItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(recurringItems);
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
