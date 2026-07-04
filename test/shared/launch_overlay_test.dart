import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/constants/app_constants.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/shared/widgets/widgets.dart';

void main() {
  Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
        theme: AppTheme.dark(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: LaunchOverlay(child: child),
        ),
      );

  testWidgets('plays the brand moment, then dissolves into the app',
      (tester) async {
    await tester.pumpWidget(host(const Text('home')));
    expect(tester.takeException(), isNull);

    // During the moment: mark and motto are on top of the app.
    await tester.pump(AppMotion.launch * 0.5);
    expect(find.byType(AnimatedBrandMark), findsOneWidget);
    expect(find.text(AppConstants.motto), findsOneWidget);

    // After: overlay is gone entirely, app remains.
    await tester.pumpAndSettle();
    expect(find.byType(AnimatedBrandMark), findsNothing);
    expect(find.text(AppConstants.motto), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('lets input through once the dissolve starts', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      host(
        Center(
          child: GestureDetector(
            onTap: () => tapped = true,
            child: const Text('tap me'),
          ),
        ),
      ),
    );

    // Mid-dissolve the layer is still visible but no longer eats taps.
    await tester.pump(AppMotion.launch * 0.9);
    await tester.tap(find.text('tap me'), warnIfMissed: false);
    expect(tapped, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('is skipped entirely under reduce-motion', (tester) async {
    await tester.pumpWidget(host(const Text('home'), reduceMotion: true));
    expect(tester.takeException(), isNull);

    expect(find.byType(AnimatedBrandMark), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
