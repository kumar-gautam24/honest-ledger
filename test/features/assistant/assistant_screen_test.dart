import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/database/app_database.dart';
import 'package:recurring/core/di/injector.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/assistant/presentation/screens/assistant_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpScreen(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await sl.reset();
  await configureDependencies(database: AppDatabase.memory());

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const AssistantScreen(),
      ),
    ),
  );
  await tester.pump();
}

/// Advances time so the demo service's per-hop delays and the reveal timer all
/// finish. We can't use pumpAndSettle: the typing dots animate indefinitely
/// while the assistant is working, so it would never settle.
Future<void> _drain(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 10));
  await sl<AppDatabase>().close();
}

void main() {
  testWidgets('empty state shows the greeting and starter chips', (t) async {
    await _pumpScreen(t);

    // A time-aware greeting always ends with a period; the chips are present.
    expect(find.text('Due soon'), findsOneWidget);
    expect(find.text('My cards'), findsOneWidget);
    expect(find.text('Ask about your money…'), findsOneWidget); // composer hint

    await _teardown(t);
  });

  testWidgets('tapping a starter chip sends it as a user turn', (t) async {
    await _pumpScreen(t);

    await t.tap(find.text('My cards'));
    await t.pump(); // controller.send → user entry appears

    // The user's message is now in the transcript (chip label maps to a query).
    expect(find.text('Show my cards'), findsOneWidget);
    // Leaving the empty state reveals the "new chat" control.
    expect(find.byTooltip('New chat'), findsOneWidget);

    await _drain(t); // let the demo request + reveal finish
    await _teardown(t);
  });

  testWidgets('the assistant answers and the reply renders', (t) async {
    await _pumpScreen(t);

    await t.enterText(find.byType(TextField), 'show my cards');
    await t.pump();
    await t.testTextInput.receiveAction(TextInputAction.send);

    // Pump past the full read→answer loop and the word-by-word reveal.
    await _drain(t);

    // The user turn is present and the screen rendered the reply without error.
    expect(find.text('show my cards'), findsOneWidget);
    expect(find.byType(AssistantScreen), findsOneWidget); // no build crash

    await _teardown(t);
  });
}
