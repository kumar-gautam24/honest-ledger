import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Standard form scaffold used across the app.
///
/// Handles three things every form needs, in one place:
/// - **tap-outside-to-dismiss** the keyboard,
/// - **keyboard-aware scrolling** (content lifts above the keyboard inset),
/// - consistent screen padding.
///
/// Fields move focus with `textInputAction: TextInputAction.next` and the
/// shared `AppTextField`; the final field uses `.done`.
class AppForm extends StatelessWidget {
  const AppForm({
    super.key,
    this.formKey,
    required this.child,
    this.padding = AppSpacing.screen,
  });

  final GlobalKey<FormState>? formKey;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: padding.copyWith(bottom: padding.bottom + viewInsets),
          child: child,
        ),
      ),
    );
  }
}

/// Moves focus to [next] (or unfocuses if null). Use from a field's
/// `onFieldSubmitted` to chain inputs.
void advanceFocus(BuildContext context, FocusNode? next) {
  if (next != null) {
    FocusScope.of(context).requestFocus(next);
  } else {
    FocusScope.of(context).unfocus();
  }
}
