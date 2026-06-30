import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

/// Recurring tab — subscriptions, bills and EMIs. Built in a later phase.
class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Recurring',
      body: EmptyState(
        icon: Icons.event_repeat_rounded,
        title: 'No recurring items yet',
        message:
            'Track subscriptions, bills and EMIs here to see your true monthly '
            'outflow at a glance.',
      ),
    );
  }
}
