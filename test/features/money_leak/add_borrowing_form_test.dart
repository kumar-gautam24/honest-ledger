import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/money_leak/presentation/screens/add_edit_borrowing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `_save()` pops via go_router's `context.pop()`, so the save-flow test
/// needs a real GoRouter in the tree (a plain `MaterialApp(home: ...)` has
/// none, and popping with nothing to pop to hangs the widget under test).
Widget _routedApp() {
  final router = GoRouter(
    initialLocation: '/add',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/add',
        builder: (_, _) => const AddEditBorrowingScreen(),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      theme: AppTheme.dark(),
      routerConfig: router,
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  testWidgets('empty submit surfaces validation errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AddEditBorrowingScreen(),
        ),
      ),
    );
    await tester.pump();

    final button = find.widgetWithText(FilledButton, 'Add borrowing');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Name the purchase'), findsOneWidget);
    expect(find.text('Enter the amount'), findsOneWidget);
  });

  testWidgets(
      'toggling no-cost EMI forces GST on and shows the advertised-vs-actual receipt',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AddEditBorrowingScreen(),
        ),
      ),
    );
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'iPhone'); // title
    await tester.enterText(fields.at(1), '75000'); // principal
    await tester.enterText(fields.at(2), '15'); // bank rate behind the offer
    await tester.enterText(fields.at(3), '6'); // tenure
    await tester.pump();

    // Before toggling: GST switch is off and editable, no no-cost receipt.
    expect(
      find.widgetWithText(SwitchListTile, 'GST on interest (18%)'),
      findsOneWidget,
    );
    expect(find.text('NO-COST EMI — ADVERTISED VS ACTUAL'), findsNothing);

    final noCostSwitch = find.widgetWithText(SwitchListTile, 'No-cost EMI');
    await tester.ensureVisible(noCostSwitch);
    await tester.pump();
    await tester.tap(noCostSwitch);
    await tester.pumpAndSettle();

    // GST switch is now forced on and disabled.
    final gstTile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'GST on interest (18%)'),
    );
    expect(gstTile.value, isTrue);
    expect(gstTile.onChanged, isNull);
    expect(find.text('Always charged on no-cost EMIs'), findsOneWidget);

    // The receipt-grade preview replaces the regular estimate.
    expect(find.text('NO-COST EMI — ADVERTISED VS ACTUAL'), findsOneWidget);
    expect(find.text('Seller discount covers interest'), findsOneWidget);
    expect(find.text('Really costs you extra'), findsOneWidget);
  });

  testWidgets('saving a no-cost EMI persists isNoCostEmi and gstOnInterest',
      (tester) async {
    await tester.pumpWidget(_routedApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'iPhone'); // title
    await tester.enterText(fields.at(1), '75000'); // principal
    await tester.enterText(fields.at(2), '15'); // bank rate behind the offer
    await tester.enterText(fields.at(3), '6'); // tenure
    await tester.pump();

    final noCostSwitch = find.widgetWithText(SwitchListTile, 'No-cost EMI');
    await tester.ensureVisible(noCostSwitch);
    await tester.pump();
    await tester.tap(noCostSwitch);
    await tester.pump();

    final button = find.widgetWithText(FilledButton, 'Add borrowing');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pumpAndSettle();

    // Read the persisted row directly off the (in-memory) database — a
    // one-shot query, unlike the repository's live `watchSummaries` stream,
    // which leaves a subscription that races the widget test's teardown.
    final rows = await sl<AppDatabase>().select(sl<AppDatabase>().borrowings).get();
    expect(rows, hasLength(1));
    expect(rows.single.isNoCostEmi, isTrue);
    expect(rows.single.gstOnInterest, isTrue);
  });
}
