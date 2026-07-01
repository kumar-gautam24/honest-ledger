import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/forms/amount_input_formatter.dart';

void main() {
  final formatter = IndianAmountInputFormatter();

  String format(String input) => formatter
      .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input))
      .text;

  test('groups thousands with Indian separators', () {
    expect(format('75000'), '75,000');
    expect(format('100000'), '1,00,000');
    expect(format('1000000'), '10,00,000');
  });

  test('keeps a decimal tail and caps at two places', () {
    expect(format('1234.5'), '1,234.5');
    expect(format('10.999'), '10.99');
  });

  test('handles empty and lone dot gracefully', () {
    expect(format(''), '');
    expect(format('.'), '0.');
  });

  test('strips existing commas before regrouping', () {
    expect(format('7,50,00'), '75,000');
  });
}
