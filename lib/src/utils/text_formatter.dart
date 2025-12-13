// 🐦 Flutter imports:
import 'package:flutter/services.dart';
import 'package:form_architect/src/utils/string_ext.dart';

/// A text input formatter for floating point values.
class FloatingPointInputFormatter extends TextInputFormatter {
  /// The maximum number of decimal places allowed.
  final int decimalPlaces;

  FloatingPointInputFormatter({this.decimalPlaces = 2})
    : assert(decimalPlaces >= 0, 'Decimal places must be non-negative');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty input.
    if (text.isEmpty) return newValue;

    // Ensure the input is a valid number, allowing negative values.
    final number = double.tryParse(text);
    if (number == null) return oldValue;

    // Limit the number of decimal places.
    final parts = text.split('.');
    if (parts.length > 1 && parts[1].length > decimalPlaces) {
      return oldValue;
    }

    return newValue;
  }
}

/// A text input formatter that only allows integer values.
class IntegerTextInputFormatter extends TextInputFormatter {
  /// The minimum value allowed (optional).
  final int? minValue;

  /// The maximum value allowed (optional).
  final int? maxValue;

  /// Whether to allow negative values.
  final bool allowNegative;

  IntegerTextInputFormatter({
    this.minValue,
    this.maxValue,
    this.allowNegative = true,
  }) : assert(
         minValue == null || maxValue == null || minValue <= maxValue,
         'Min value must be less than or equal to max value',
       );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Allow empty input
    if (text.isEmpty) {
      return newValue;
    }

    // Allow a single minus sign if negative values are permitted
    if (allowNegative && text == '-') {
      return newValue;
    }

    // Check that the input contains only digits (and possibly a leading minus sign)
    final validIntegerPattern = allowNegative ? r'^-?\d*$' : r'^\d*$';
    if (!RegExp(validIntegerPattern).hasMatch(text)) {
      return oldValue;
    }

    // If it's just a minus sign, accept it
    if (text == '-') {
      return newValue;
    }

    // Parse the integer
    final number = int.tryParse(text);
    if (number == null) {
      return oldValue;
    }

    // Check minimum value constraint
    if (minValue != null && number < minValue!) {
      return oldValue;
    }

    // Check maximum value constraint
    if (maxValue != null && number > maxValue!) {
      return oldValue;
    }

    return newValue;
  }
}

/// A text input formatter that limits the number of words.
class WordCountTextInputFormatter extends TextInputFormatter {
  /// The maximum number of words allowed.
  final int maxWords;

  /// Whether to count consecutive whitespace as a single separator.
  final bool treatConsecutiveWhitespaceAsSingle;

  WordCountTextInputFormatter({
    required this.maxWords,
    this.treatConsecutiveWhitespaceAsSingle = true,
  }) : assert(maxWords > 0, 'Max words must be positive');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final wordLimit = maxWords + 1;
    // Allow empty input
    if (text.isEmpty) {
      return newValue;
    }

    // Count words
    final wordCount = text.wordCount(
      treatConsecutiveWhitespaceAsSingle: treatConsecutiveWhitespaceAsSingle,
    );

    // If word count is within limit, allow the change
    if (wordCount <= wordLimit) {
      return newValue;
    }

    // If we're over the limit, check if this is a reduction from the old value
    final oldWordCount = oldValue.text.wordCount(
      treatConsecutiveWhitespaceAsSingle: treatConsecutiveWhitespaceAsSingle,
    );

    // Allow reduction: if new word count is less than or equal to old word count
    if (wordCount <= oldWordCount) {
      return newValue;
    }

    // If trying to add more words when already over limit, trim to word limit
    final trimmedText = _trimToWordLimit(text, maxWords);

    // Calculate the new cursor position
    final originalSelection = newValue.selection;
    final trimmedLength = trimmedText.length;
    final originalLength = text.length;

    // Adjust cursor position if text was trimmed
    int newCursorPosition = originalSelection.baseOffset;
    if (originalLength > trimmedLength) {
      // If text was trimmed from the end, keep cursor position
      // If cursor was beyond trimmed text, move it to end
      newCursorPosition = newCursorPosition > trimmedLength
          ? trimmedLength
          : newCursorPosition;
    }
    return TextEditingValue(
      text: trimmedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  /// Trims the text to contain at most [maxWords] words.
  String _trimToWordLimit(String text, int maxWords) {
    if (text.isEmpty) return text;

    final regex = treatConsecutiveWhitespaceAsSingle
        ? RegExp(r'\s+')
        : RegExp(r'\s');

    final words = text.trim().split(regex);

    if (words.length <= maxWords) {
      return text;
    }

    // Take only the first maxWords words
    final trimmedWords = words.take(maxWords).toList();
    return trimmedWords.join(' ');
  }
}
