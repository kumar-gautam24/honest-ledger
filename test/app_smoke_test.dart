import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/app/app.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots to the money-leak home with its hero', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await configureDependencies(database: AppDatabase.memory());

    await tester.pumpWidget(const ProviderScope(child: RecurringApp()));
    await tester.pump(); // build
    await tester.pump(const Duration(milliseconds: 200)); // stream emits data
    await tester.pump(); // settle into empty/data state

    // Signature hero and the four nav tabs are present.
    expect(find.text('LIFETIME WASTED'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Recurring'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);

    // Tear down the tree so drift's stream-close timer flushes within the test.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
    await sl<AppDatabase>().close();
  });
}
