import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/string_ext.dart';

/// Helper class for validating form brick values.
///
/// Provides validation functions for required, min, max, and pattern rules.
class FormValidationHelper {
  /// Validates a value against the brick's validation rules.
  ///
  /// Automatically determines validation logic based on the brick type.
  /// Returns the error message if validation fails, null otherwise.
  ///
  /// [value] - The value to validate (can be any type T)
  /// [brick] - The form brick containing validation rules
  static String? validate<T>(T? value, FormBrick<T> brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    // First check required validation (applies to all field types)
    final requiredError = _validateRequired(value, brick);
    if (requiredError != null) {
      return requiredError;
    }

    // For string-based fields, check min/max/pattern validations
    if (value is String) {
      return _validateStringRules(value, brick);
    }

    // For selection fields (radio, dropdown), only required validation applies
    // Other validation types don't apply to selection fields
    return null;
  }

  /// Validates that a value is not null/empty if required.
  static String? _validateRequired<T>(T? value, FormBrick<T> brick) {
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

    // Check if value is null or empty
    if (value == null) {
      return requiredRule.message;
    }

    // For string values, check if empty or whitespace
    if (value is String) {
      final stringValue = value as String;
      if (stringValue.isWhiteSpace) {
        return requiredRule.message;
      }
    }

    // For list values, check if empty
    if (value is List && value.isEmpty) {
      return requiredRule.message;
    }

    return null; // Value is present
  }

  /// Validates string-specific rules (min, max, pattern) based on brick type.
  static String? _validateStringRules(String? value, FormBrick brick) {
    final validationRules = brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    // Determine if this is a numeric field based on brick type
    final isNumeric =
        brick.type == FormBrickType.integer ||
        brick.type == FormBrickType.float;

    // Apply each validation rule
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
          if (minValue != null && value != null) {
            if (isNumeric) {
              // For numeric fields, compare the numeric value
              final numValue = double.tryParse(value);
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
            } else {
              // For text fields, compare string length
              final minLength = minValue is int
                  ? minValue
                  : int.tryParse(minValue.toString());
              if (minLength != null && value.length < minLength) {
                return rule.message;
              }
            }
          }
          break;

        case FormValidationRuleType.max:
          if (value.isWhiteSpace) {
            // Skip max validation if field is empty
            continue;
          }
          final maxValue = rule.value;
          if (maxValue != null && value != null) {
            if (isNumeric) {
              // For numeric fields, compare the numeric value
              final numValue = double.tryParse(value);
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
            } else {
              // For text fields, compare string length
              final maxLength = maxValue is int
                  ? maxValue
                  : int.tryParse(maxValue.toString());
              if (maxLength != null && value.length > maxLength) {
                return rule.message;
              }
            }
          }
          break;

        case FormValidationRuleType.pattern:
          if (value.isWhiteSpace) {
            // Skip pattern validation if field is empty (required will catch it)
            continue;
          }
          final pattern = rule.value;
          if (pattern != null && pattern is String && value != null) {
            try {
              final regex = RegExp(pattern);
              if (!regex.hasMatch(value)) {
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
}
