import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/string_ext.dart';

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
    if (value is String) {
      final stringValue = value as String;
      if (stringValue.isWhiteSpace) {
        return requiredRule.message;
      }
    }

    return null; // Value is present
  }

  /// Validates text field rules (min length, max length, pattern).
  static String? validateTextRules<T>(T? value, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    final isFromTextField = value is String?;
    if (!isFromTextField) return null;
    final stringValue = value as String?;
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
            final minLength = minValue is int
                ? minValue
                : int.tryParse(minValue.toString());
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
            final maxLength = maxValue is int
                ? maxValue
                : int.tryParse(maxValue.toString());
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

    final isFromTextField = value is String?;
    if (!isFromTextField) return null;
    final stringValue = value as String?;
    if (stringValue == null) return null;

    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          // Required validation already handled
          continue;

        case FormValidationRuleType.min:
          if (value.isWhiteSpace) {
            // Skip min validation if field is empty (required will catch it)
            continue;
          }
          final minValue = rule.value;
          if (minValue != null) {
            // For numeric fields, compare the numeric value
            final numValue = num.tryParse(stringValue);
            if (numValue == null) {
              // Invalid number format, skip min check
              continue;
            }
            final minNum = minValue is num
                ? minValue
                : num.tryParse(minValue.toString());
            if (minNum != null && numValue < minNum) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.max:
          if (value.isWhiteSpace) {
            // Skip max validation if field is empty
            continue;
          }
          final maxValue = rule.value;
          if (maxValue != null) {
            final numValue = double.tryParse(stringValue);
            if (numValue == null) {
              // Invalid number format, skip max check
              continue;
            }
            final maxNum = maxValue is num
                ? maxValue
                : num.tryParse(maxValue.toString());
            if (maxNum != null && numValue > maxNum) {
              return rule.message;
            }
          }
          break;

        case FormValidationRuleType.pattern:
          // Generally not applied for numeric fields, but handle if present.
          if (value.isWhiteSpace) {
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
            final minNum = minValue is num
                ? minValue
                : num.tryParse(minValue.toString());
            if (minNum != null && valueCount < minNum) {
              return rule.message;
            }
          }
          break;
        case FormValidationRuleType.max:
          // For multi-select, "max" means maximum # of selections
          final maxValue = rule.value;
          if (maxValue != null) {
            final maxNum = maxValue is num
                ? maxValue
                : num.tryParse(maxValue.toString());
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
}
