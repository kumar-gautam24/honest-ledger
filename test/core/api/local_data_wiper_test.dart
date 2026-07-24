import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/local_data_wiper.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/features/assistant/application/assistant_state.dart';
import 'package:recurring/features/assistant/data/assistant_repository.dart';
import 'package:recurring/features/assistant/domain/entities/ai_message.dart';
import 'package:recurring/features/cards/data/card_repository_impl.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/lenders/data/lender_repository_impl.dart';
import 'package:recurring/features/lenders/domain/entities/lender.dart';
import 'package:recurring/features/money_leak/data/borrowing_repository_impl.dart';
import 'package:recurring/features/money_leak/domain/entities/borrowing.dart';
import 'package:recurring/features/money_leak/domain/entities/repayment.dart';
import 'package:recurring/features/recurring/data/recurring_repository_impl.dart';
import 'package:recurring/features/recurring/domain/entities/recurring_item.dart';
import 'package:recurring/features/settings/presentation/controllers/income_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('wipe clears account data but keeps the catalog and device prefs',
      () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    SharedPreferences.setMockInitialValues({
      IncomeController.prefsKey: 50000.0,
      'theme_mode': 'dark', // a device preference — must survive
    });
    final prefs = await SharedPreferences.getInstance();

    // Seed one row per account table, plus a built-in lender that must survive.
    final lenders = LenderRepositoryImpl(db);
    await lenders.upsert(const Lender(id: 'builtin', name: 'Built-in', type: LenderType.card));
    await lenders.upsert(const Lender(id: 'mine', name: 'Mine', type: LenderType.card, isMine: true));

    final borrowings = BorrowingRepositoryImpl(db);
    await borrowings.upsertBorrowing(Borrowing(
      id: 'b1',
      title: 'Loan',
      lenderName: 'x',
      kind: BorrowingKind.fixedEmi,
      principal: 10000,
      startDate: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
    ));
    await borrowings.addRepayment(
        Repayment(id: 'rp1', borrowingId: 'b1', amount: 500, date: DateTime(2026, 2, 1)));

    final cards = CardRepositoryImpl(db);
    await cards.upsertCard(CardAccount(
      id: 'c1',
      lenderId: 'l',
      name: 'Card',
      statementDay: 5,
      dueDay: 25,
      creditLimit: 100000,
      createdAt: DateTime(2026, 1, 1),
    ));
    await cards.upsertStatement(CardStatement(
      id: 's1',
      cardId: 'c1',
      cycleMonth: DateTime(2026, 7, 1),
      statementAmount: 1200,
      dueDate: DateTime(2026, 7, 25),
    ));

    final recurring = RecurringRepositoryImpl(db);
    await recurring.upsert(RecurringItem(
      id: 'r1',
      title: 'Netflix',
      amount: 649,
      type: RecurringType.subscription,
      frequency: Frequency.monthly,
      nextDueDate: DateTime(2026, 8, 1),
      createdAt: DateTime(2026, 1, 1),
    ));

    // A saved assistant conversation — per-account, must not survive sign-out.
    final assistant = AssistantRepository(prefs);
    await assistant.save(
      entries: [const ChatEntry(id: '1', role: ChatRole.user, text: 'hi')],
      wire: [const AiChatMessage.user('hi')],
    );

    await LocalDataWiperImpl(db, prefs, assistant).wipe();

    // Account tables are empty.
    expect(await db.select(db.borrowings).get(), isEmpty);
    expect(await db.select(db.repayments).get(), isEmpty);
    expect(await db.select(db.cards).get(), isEmpty);
    expect(await db.select(db.cardStatements).get(), isEmpty);
    expect(await db.select(db.recurringItems).get(), isEmpty);

    // Built-in catalog survives; the user's own lender is gone.
    final remainingLenders = await db.select(db.lenders).get();
    expect(remainingLenders.map((l) => l.id), ['builtin']);

    // Income pref cleared; device pref untouched.
    expect(prefs.getDouble(IncomeController.prefsKey), isNull);
    expect(prefs.getString('theme_mode'), 'dark');

    // The assistant conversation is forgotten so the next account can't see it.
    expect(assistant.load(), isNull);
  });
}
