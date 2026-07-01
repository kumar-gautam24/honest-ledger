import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/money_leak/presentation/screens/add_edit_borrowing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
