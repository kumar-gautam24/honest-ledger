import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/theme/app_theme.dart';
import 'package:recurring/features/auth/presentation/sync_overlay.dart';
import 'package:recurring/shared/widgets/widgets.dart';

void main() {
  testWidgets('shows the brand mark, status and a progress track',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const SyncOverlay(),
    ));
    await tester.pump(); // let the indeterminate indicator start

    expect(tester.takeException(), isNull);
    expect(find.byType(AnimatedBrandMark), findsOneWidget);
    expect(find.text('Syncing your data'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
