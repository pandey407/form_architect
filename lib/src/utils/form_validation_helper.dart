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
    if (brick.type.isMultiSelectType) {
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
          // Required validation already handled
          continue;

        case FormValidationRuleType.min:
          if (stringValue.isWhiteSpace) {
            // Skip min length validation if field is empty (required will catch it)
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
            // Skip max length validation if field is empty
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
            // Skip pattern validation if field is empty (required will catch it)
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
              // Invalid regex pattern, skip this validation
              continue;
            }
          }
          break;
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
          // Required validation already handled
          continue;

        case FormValidationRuleType.min:
          if (stringValue.isWhiteSpace) {
            // Skip min validation if field is empty (required will catch it)
            continue;
          }
          final minValue = rule.value;
          if (minValue != null) {
            // Use TypeParserHelper to parse as num
            final numValue = TypeParserHelper.parseNum(stringValue);
            if (numValue == null) {
              // Invalid number format, skip min check
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
            // Skip max validation if field is empty
            continue;
          }
          final maxValue = rule.value;
          if (maxValue != null) {
            final numValue = TypeParserHelper.parseNum(stringValue);
            if (numValue == null) {
              // Invalid number format, skip max check
              continue;
            }
            final maxNum = TypeParserHelper.parseNum(maxValue);
            if (maxNum != null && numValue > maxNum) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.pattern:
          // Pattern validation typically do not apply to numeric field.
          continue;
      }
    }

    return null; // All validations passed
  }

  /// Validates a list of selected values for a multi-select dropdown.
  ///
  /// [values] - The list of selected values
  /// [brick]  - The FormBrick instance containing validation rules
  ///
  /// Returns the error message if validation fails, otherwise null.
  static String? validateMultiSelectRules<E>(List<E>? values, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }
    final valueCount = values?.length ?? 0;

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Required validation already handled
          continue;

        case FormValidationRuleType.min:
          // For multi-select, "min" means minimum # of selections
          final minValue = rule.value;
          if (minValue != null) {
            final minNum = TypeParserHelper.parseNum(minValue);
            if (minNum != null && valueCount < minNum) {
              return rule.message;
            }
          }
          break;
        case FormValidationRuleType.max:
          // For multi-select, "max" means maximum # of selections
          final maxValue = rule.value;
          if (maxValue != null) {
            final maxNum = TypeParserHelper.parseNum(maxValue);
            if (maxNum != null && valueCount > maxNum) {
              return rule.message;
            }
          }
          break;
        default:
          // Pattern validation typically do not apply to multi-select.
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
      // If value can't be parsed, skip further date validation
      return null;
    }

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Required validation already handled
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
        default:
          // Pattern validation typically do not apply to date time field, instead the pattern is used for value transformation to required format.
          break;
      }
    }
    return null;
  }
}
