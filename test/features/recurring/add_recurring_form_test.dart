import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/cards/presentation/controllers/card_providers.dart';
import 'package:recurring/features/recurring/presentation/screens/add_edit_recurring_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The card picker watches [cardsProvider]; override it with a static empty
/// list so tests don't open a live DB stream (which leaves a pending timer).
final _noCards = cardsProvider.overrideWith((ref) => Stream.value(const []));

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());
  });

  testWidgets('empty submit surfaces a validation error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [_noCards],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const AddEditRecurringScreen(),
        ),
      ),
    );
    await tester.pump();

    final button = find.widgetWithText(FilledButton, 'Add item');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Give it a name'), findsOneWidget);
  });
}
