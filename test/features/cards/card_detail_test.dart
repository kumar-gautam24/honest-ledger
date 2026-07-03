import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/core/utils/date_x.dart';
import 'package:recurring/features/cards/domain/entities/card_account.dart';
import 'package:recurring/features/cards/domain/entities/card_cycle.dart';
import 'package:recurring/features/cards/domain/entities/card_statement.dart';
import 'package:recurring/features/cards/presentation/controllers/card_providers.dart';
import 'package:recurring/features/cards/presentation/screens/card_detail_screen.dart';
import 'package:recurring/features/money_leak/presentation/controllers/money_leak_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/fixtures.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  testWidgets('card detail shows the bill, EMI/spends split and history',
      (tester) async {
    final cycle = CardCycle.cycleFor(now: DateTime.now(), statementDay: 15);
    final card = CardAccount(
      id: 'c1',
      lenderId: 'l-icici',
      name: 'ICICI Amazon Pay',
      statementDay: 15,
      dueDay: 3,
      creditLimit: 100000,
      createdAt: DateTime(2026, 1, 1),
    );
    final statement = CardStatement(
      id: 's1',
      cardId: 'c1',
      cycleMonth: cycle,
      statementAmount: 18400,
      dueDate: CardCycle.dueDateFor(
        cycleMonth: cycle,
        statementDay: 15,
        dueDay: 3,
      ),
    );
    // EMI on this card: installment #1 due the 1st of the cycle month —
    // inside the (15th prev, 15th] window → ₹1,000 of the bill is EMIs.
    final emi = emiSummary(
      startDate: cycle.addMonths(-1),
      lenderId: 'l-icici',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardsProvider.overrideWith((ref) => Stream.value([card])),
          cardStatementsProvider('c1')
              .overrideWith((ref) => Stream.value([statement])),
          borrowingSummariesProvider
              .overrideWith((ref) => Stream.value([emi])),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const CardDetailScreen(cardId: 'c1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ICICI Amazon Pay'), findsOneWidget);
    expect(find.textContaining('18,400'), findsWidgets);
    expect(find.text('EMIs on this bill'), findsOneWidget);
    expect(find.text('Other spends'), findsOneWidget);
    expect(find.text('HISTORY'), findsOneWidget);
    expect(find.textContaining('EMIs · '), findsOneWidget);

    // The linked-EMIs section builds lazily below the fold.
    await tester.scrollUntilVisible(
      find.text('Phone EMI'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('EMIS ON THIS CARD'), findsOneWidget);
    expect(find.text('Phone EMI'), findsOneWidget);
  });
}
