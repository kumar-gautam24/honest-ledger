import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/shared/widgets/widgets.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('BrandMark paints at the requested size', (tester) async {
    await tester.pumpWidget(host(const BrandMark(size: 88)));
    expect(tester.takeException(), isNull);

    final paintFinder = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is BrandMarkPainter,
    );
    expect(paintFinder, findsOneWidget);
    expect(tester.getSize(paintFinder), const Size(88, 88));
  });

  testWidgets('AnimatedBrandMark plays once and settles', (tester) async {
    await tester.pumpWidget(host(const AnimatedBrandMark(size: 88)));
    expect(tester.takeException(), isNull);

    // Mid-animation the drop has not landed yet.
    await tester.pump(AppMotion.counter * 0.3);
    CustomPaint paint = tester.widget(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BrandMarkPainter,
      ),
    );
    var painter = paint.painter as BrandMarkPainter;
    expect(painter.dropProgress, lessThan(1));

    // Settles at the finished mark with no timers left behind.
    await tester.pumpAndSettle();
    paint = tester.widget(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BrandMarkPainter,
      ),
    );
    painter = paint.painter as BrandMarkPainter;
    expect(painter.ringProgress, 1);
    expect(painter.dropProgress, 1);
  });

  testWidgets('AnimatedBrandMark renders instantly under reduce-motion',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: Center(child: AnimatedBrandMark(size: 88))),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    final paint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BrandMarkPainter,
      ),
    );
    final painter = paint.painter as BrandMarkPainter;
    expect(painter.ringProgress, 1);
    expect(painter.dropProgress, 1);
    // No animation scheduled — nothing to settle.
    expect(tester.binding.transientCallbackCount, 0);
  });
}
