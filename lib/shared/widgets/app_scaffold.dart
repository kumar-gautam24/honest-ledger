import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Consistent page chrome: themed background, optional title bar, safe-area
/// body. Screens supply only their content.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padBody = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// Wrap [body] in the standard screen padding.
  final bool padBody;

  @override
  Widget build(BuildContext context) {
    final content = padBody
        ? Padding(padding: AppSpacing.screen, child: body)
        : body;

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              leading: leading,
            ),
      body: SafeArea(top: title == null, child: content),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
