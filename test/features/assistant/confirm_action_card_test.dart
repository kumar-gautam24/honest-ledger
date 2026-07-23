import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/assistant/domain/entities/proposed_action.dart';
import 'package:recurring/features/assistant/presentation/widgets/confirm_action_card.dart';

Widget _app(Widget child) =>
    MaterialApp(theme: AppTheme.dark(), home: Scaffold(body: child));

void main() {
  testWidgets('renders an editable field with a diff and confirms edited values',
      (tester) async {
    Map<String, String>? confirmed;
    const action = ProposedAction(
      toolCallId: 'w1',
      kind: ProposedActionKind.setCardStatement,
      title: 'Update card statement',
      summary: 'ICICI · ₹2,000',
      fields: [
        ActionField(
          key: 'statement_amount',
          label: 'Outstanding',
          type: ActionFieldType.amount,
          value: '2000',
          oldValue: '1500',
        ),
      ],
    );

    await tester.pumpWidget(_app(ConfirmActionCard(
      action: action,
      onConfirm: (e) => confirmed = e,
      onCancel: () {},
    )));
    await tester.pump();

    expect(find.text('Update card statement'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
    expect(find.textContaining('was'), findsOneWidget); // old → new diff
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);

    // Edit the amount, then confirm — the edited value comes back.
    await tester.enterText(find.byType(TextFormField).first, '2500');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump();

    expect(confirmed, isNotNull);
    expect(confirmed!['statement_amount']!.replaceAll(',', ''), '2500');
  });

  testWidgets('a destructive action shows a warning and a Delete button, and Cancel works',
      (tester) async {
    var cancelled = false;
    const action = ProposedAction(
      toolCallId: 'd1',
      kind: ProposedActionKind.deleteSubscription,
      title: 'Delete subscription',
      summary: 'Netflix',
      destructive: true,
      warning: 'This permanently removes "Netflix".',
    );

    await tester.pumpWidget(_app(ConfirmActionCard(
      action: action,
      onConfirm: (_) {},
      onCancel: () => cancelled = true,
    )));
    await tester.pump();

    expect(find.textContaining('permanently removes'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Delete'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pump();
    expect(cancelled, isTrue);
  });
}
