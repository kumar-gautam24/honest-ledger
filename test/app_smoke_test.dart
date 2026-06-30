import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/app/app.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots to the money-leak home with its hero', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();

    await tester.pumpWidget(const ProviderScope(child: RecurringApp()));
    await tester.pump();

    // Signature hero and the four nav tabs are present.
    expect(find.text('LIFETIME WASTED'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Recurring'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
  });
}
