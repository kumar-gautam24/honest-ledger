import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Groups digits with Indian-locale separators as the user types
/// (`75000` → `75,000`, `100000` → `1,00,000`) while preserving a decimal tail.
///
/// Wired into `AppTextField.amount`, so every money field gets it for free.
/// All amount parsing strips commas, so this is display-only.
class IndianAmountInputFormatter extends TextInputFormatter {
  IndianAmountInputFormatter({this.maxDecimals = 2});

  final int maxDecimals;
  static final NumberFormat _grouper =
      NumberFormat.decimalPattern(AppConstants.locale);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return const TextEditingValue();
    if (raw == '.') return _atEnd('0.');

    // Reject anything but digits and a single dot (also filtered upstream).
    if (RegExp(r'[^0-9.]').hasMatch(raw)) return oldValue;
    if ('.'.allMatches(raw).length > 1) return oldValue;

    final parts = raw.split('.');
    final intPart = parts[0];
    final hasDot = parts.length > 1;
    var dec = hasDot ? parts[1] : '';
    if (dec.length > maxDecimals) dec = dec.substring(0, maxDecimals);

    var groupedInt = intPart.isEmpty ? '' : _grouper.format(int.parse(intPart));
    if (groupedInt.isEmpty && hasDot) groupedInt = '0';

    return _atEnd(hasDot ? '$groupedInt.$dec' : groupedInt);
  }

  TextEditingValue _atEnd(String text) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
}
