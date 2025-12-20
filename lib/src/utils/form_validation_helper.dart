import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/string_ext.dart';
import 'package:form_architect/src/utils/type_parser_helper.dart';

/// Helper class for validating form brick values.
///
/// Provides validation functions for required, min, max, and pattern rules.
class FormValidationHelper {
  /// Validates that a value is not null/empty if required.
  static String? validateRequired<T>({
    T? value,
    List<T>? values,
    required FormBrick<T> brick,
  }) {
    if (!brick.isRequired) {
      return null;
    }

    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    // Find the required rule
    final requiredRule = validationRules.firstWhere(
      (rule) => rule.type == FormValidationRuleType.required,
    );
    if (brick.type.isMultiValueType) {
      // For list values, check if empty
      if (values == null) {
        return requiredRule.message;
      }
      if (values.isEmpty) {
        return requiredRule.message;
      }
    } else {
      // Check if value is null or empty
      if (value == null) {
        return requiredRule.message;
      }
    }

    // For string values, check if empty or whitespace
    final parsedStr = TypeParserHelper.parseString(value);
    if (parsedStr != null && (parsedStr.isWhiteSpace)) {
      return requiredRule.message;
    }

    return null; // Value is present
  }

  /// Validates text field rules (min length, max length, pattern).
  static String? validateTextRules<T>(T? value, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    final stringValue = TypeParserHelper.parseString(value);
    if (stringValue == null) return null;

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Skip 'required' here, handled separately in validateRequired.
          continue;

        case FormValidationRuleType.min:
          if (stringValue.isWhiteSpace) {
            // Skip min length if empty: only 'required' checks emptiness.
            continue;
          }
          final minValue = rule.value;
          if (minValue != null) {
            final minLength = TypeParserHelper.parseNum(minValue)?.toInt();
            if (minLength != null && stringValue.length < minLength) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.max:
          if (stringValue.isWhiteSpace) {
            // Skip max length if empty: only 'required' checks emptiness.
            continue;
          }
          final maxValue = rule.value;
          if (maxValue != null) {
            final maxLength = TypeParserHelper.parseNum(maxValue)?.toInt();
            if (maxLength != null && stringValue.length > maxLength) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.pattern:
          if (stringValue.isWhiteSpace) {
            // Skip pattern if empty: only 'required' checks emptiness.
            continue;
          }
          final pattern = rule.value;
          if (pattern != null && pattern is String) {
            try {
              final regex = RegExp(pattern);
              if (!regex.hasMatch(stringValue)) {
                return rule.message;
              }
            } catch (e) {
              // Skip invalid regex patterns for pattern rules.
              continue;
            }
          }
          break;
        case FormValidationRuleType.allowedFileExtensions:
          // Skip allowedFileExtensions: only applies for file upload fields.
          continue;
      }
    }

    return null; // All validations passed
  }

  /// Validates numeric field rules (min value, max value).
  static String? validateNumericRules<T>(T? value, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    final stringValue = TypeParserHelper.parseString(value);
    if (stringValue == null) return null;

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Skip 'required' here, handled separately in validateRequired.
          continue;

        case FormValidationRuleType.min:
          if (stringValue.isWhiteSpace) {
            // Skip min validation if input is empty, 'required' handles emptiness.
            continue;
          }
          final minValue = rule.value;
          if (minValue != null) {
            // Use TypeParserHelper to parse as num
            final numValue = TypeParserHelper.parseNum(stringValue);
            if (numValue == null) {
              // Skip min validation if input can't be parsed as number.
              continue;
            }
            final minNum = TypeParserHelper.parseNum(minValue);
            if (minNum != null && numValue < minNum) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.max:
          if (stringValue.isWhiteSpace) {
            // Skip max validation if input is empty, 'required' handles emptiness.
            continue;
          }
          final maxValue = rule.value;
          if (maxValue != null) {
            final numValue = TypeParserHelper.parseNum(stringValue);
            if (numValue == null) {
              // Skip max validation if input can't be parsed as number.
              continue;
            }
            final maxNum = TypeParserHelper.parseNum(maxValue);
            if (maxNum != null && numValue > maxNum) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.pattern:
          // Skip 'pattern' for numeric fields: pattern is not relevant to numeric validation.
          continue;

        case FormValidationRuleType.allowedFileExtensions:
          // Skip allowedFileExtensions: only applies to file fields.
          continue;
      }
    }

    return null; // All validations passed
  }

  /// Validates a list of selected values for any multi-value field:
  /// e.g., multi-select dropdown, image, video, or file pickers.
  ///
  /// [values] - The list of selected values (e.g., selected options or file paths)
  /// [brick]  - The FormBrick instance containing relevant validation rules
  ///
  /// Returns the error message if validation fails, otherwise null.
  static String? validateMultiValueRules<E>(List<E>? values, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }
    final valueCount = values?.length ?? 0;

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Skip 'required' here, handled separately in validateRequired.
          continue;

        case FormValidationRuleType.min:
          // min refers to the minimum number of selected items.
          final minValue = rule.value;
          if (minValue != null) {
            final minNum = TypeParserHelper.parseNum(minValue);
            if (minNum != null && valueCount < minNum) {
              return rule.message;
            }
          }
          break;
        case FormValidationRuleType.max:
          // max refers to the maximum number of selected items.
          final maxValue = rule.value;
          if (maxValue != null) {
            final maxNum = TypeParserHelper.parseNum(maxValue);
            if (maxNum != null && valueCount > maxNum) {
              return rule.message;
            }
          }
          break;
        case FormValidationRuleType.pattern:
          // Skip 'pattern' for multi-value fields: not relevant.
          continue;

        case FormValidationRuleType.allowedFileExtensions:
          // Applies for fields where the selected values are file paths (e.g., file/image/video pickers)
          if (values == null || values.isEmpty) continue;
          final allowed = TypeParserHelper.parseAllowedExtensions(rule.value);

          if (allowed != null && allowed.isNotEmpty) {
            for (final filePath in values) {
              if (filePath is String) {
                final ext = filePath.extension;
                if (ext != null && !allowed.contains(ext)) {
                  return rule.message;
                }
              }
            }
          }
          break;
      }
    }
    return null;
  }

  /// Validates a date/datetime/time field against min/max validation rules.
  ///
  /// [value] - The field value, which should be a [DateTime], String, or num (timestamp).
  /// [brick] - The [FormBrick] instance (should be of date/time type)
  ///
  /// Returns the error message if validation fails, null otherwise.
  static String? validateDateTimeRules(dynamic value, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }
    // Parse the value to DateTime
    final dt = TypeParserHelper.parseDateTime(value);
    if (dt == null) {
      // If value can't be parsed as DateTime, skip further validation.
      return null;
    }

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Skip 'required' here, handled separately in validateRequired.
          continue;
        case FormValidationRuleType.min:
          final minValue = rule.value;
          if (minValue != null) {
            final minDt = TypeParserHelper.parseDateTime(minValue);
            if (minDt != null && dt.isBefore(minDt)) {
              return rule.message;
            }
          }
          break;
        case FormValidationRuleType.max:
          final maxValue = rule.value;
          if (maxValue != null) {
            final maxDt = TypeParserHelper.parseDateTime(maxValue);
            if (maxDt != null && dt.isAfter(maxDt)) {
              return rule.message;
            }
          }
          break;
        case FormValidationRuleType.pattern:
          // Skip 'pattern' for date/time fields: not applicable, it instead represents the output format.
          continue;

        case FormValidationRuleType.allowedFileExtensions:
          // Skip allowedFileExtensions: relevant only for file fields.
          continue;
      }
    }
    return null;
  }
}
