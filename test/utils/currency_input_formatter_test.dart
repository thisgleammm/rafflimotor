import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raffli_motor/utils/currency_input_formatter.dart';

void main() {
  group('CurrencyInputFormatter', () {
    late CurrencyInputFormatter formatter;

    setUp(() {
      formatter = CurrencyInputFormatter();
    });

    group('formatEditUpdate', () {
      test('should format number with Indonesian locale (dot separator)', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '50000',
          selection: TextSelection.collapsed(offset: 5),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.text, '50.000');
        expect(result.selection.baseOffset, 6); // cursor at end
      });

      test('should format large numbers correctly', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '1000000',
          selection: TextSelection.collapsed(offset: 7),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.text, '1.000.000');
      });

      test('should handle small numbers', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '100',
          selection: TextSelection.collapsed(offset: 3),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.text, '100');
      });

      test('should return newValue when cursor is at position 0', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '50000',
          selection: TextSelection.collapsed(offset: 0),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result, newValue);
      });

      test('should handle input with existing dots (removing them first)', () {
        // Arrange
        const oldValue = TextEditingValue(text: '50.000');
        const newValue = TextEditingValue(
          text: '50.0005',
          selection: TextSelection.collapsed(offset: 7),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        // When removing dots: '50.0005' -> '500005' -> formatted as '500.005'
        expect(result.text, '500.005');
      });

      test('should format zero correctly', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '0',
          selection: TextSelection.collapsed(offset: 1),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.text, '0');
      });

      test('should handle millions correctly', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '5000000',
          selection: TextSelection.collapsed(offset: 7),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.text, '5.000.000');
      });

      test('should place cursor at end after formatting', () {
        // Arrange
        const oldValue = TextEditingValue(text: '');
        const newValue = TextEditingValue(
          text: '123456',
          selection: TextSelection.collapsed(offset: 6),
        );

        // Act
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // Assert
        expect(result.selection.baseOffset, result.text.length);
        expect(result.selection.isCollapsed, true);
      });
    });
  });
}
