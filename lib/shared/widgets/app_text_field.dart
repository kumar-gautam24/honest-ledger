import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/validation/validators.dart';

/// The app's text input. Pairs with [AppForm] for keyboard/focus handling.
///
/// Use [AppTextField.amount] for money inputs — it adds the ₹ prefix, a numeric
/// keyboard, and digit/decimal filtering.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onSubmitted,
    this.prefix,
    this.suffix,
    this.autofocus = false,
  });

  /// A money input with ₹ prefix and decimal numeric keyboard.
  factory AppTextField.amount({
    Key? key,
    required String label,
    TextEditingController? controller,
    String? hint,
    StringValidator? validator,
    TextInputAction textInputAction = TextInputAction.next,
    FocusNode? focusNode,
    ValueChanged<String>? onSubmitted,
    bool autofocus = false,
  }) {
    return AppTextField(
      key: key,
      label: label,
      controller: controller,
      hint: hint ?? '0',
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      textInputAction: textInputAction,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      prefix: '₹ ',
      autofocus: autofocus,
    );
  }

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final StringValidator? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final String? prefix;
  final String? suffix;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
          child: Text(label, style: AppTypography.eyebrow(c)),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: context.text.titleMedium,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            suffixText: suffix,
            prefixStyle: AppTypography.money(c, color: c.textMid),
          ),
        ),
      ],
    );
  }
}
