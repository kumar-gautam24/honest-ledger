import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/shared/widgets/widgets.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('a non-expanded button lays out inside a Row', (tester) async {
    // A Row hands its children unbounded width; an infinite minimumSize in
    // the button theme makes this crash. The button must hug its content.
    await tester.pumpWidget(
      host(
        Row(
          children: [
            const Expanded(child: SizedBox()),
            AppButton(label: 'Pay', onPressed: () {}, expand: false),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Pay'), findsOneWidget);
  });

  testWidgets('a non-expanded secondary button lays out inside a Row',
      (tester) async {
    await tester.pumpWidget(
      host(
        Row(
          children: [
            const Expanded(child: SizedBox()),
            AppButton(
              label: 'Edit',
              onPressed: () {},
              variant: AppButtonVariant.secondary,
              expand: false,
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('an expanded button still fills the available width',
      (tester) async {
    await tester.pumpWidget(
      host(AppButton(label: 'Save', onPressed: () {})),
    );
    expect(tester.takeException(), isNull);
    final buttonSize = tester.getSize(find.byType(FilledButton));
    final screenWidth = tester.getSize(find.byType(Scaffold)).width;
    expect(buttonSize.width, screenWidth);
    expect(buttonSize.height, greaterThanOrEqualTo(52));
  });
}
