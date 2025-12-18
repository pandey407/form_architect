import 'package:json_annotation/json_annotation.dart';
part 'form_validation_rule.g.dart';

/// Enum representing the type of validation rule that can be applied to a form field.
enum FormValidationRuleType {
  /// Field is required and cannot be empty.
  @JsonValue('REQUIRED')
  required,

  /// Value must be greater than or equal to a minimum value.
  ///
  /// - For number fields: checks that number >= min.
  /// - For string fields: checks that string length >= min (length).
  /// - For date/time fields: checks that date/time >= min (inclusive).
  @JsonValue('MIN')
  min,

  /// Value must be less than or equal to a maximum value.
  ///
  /// - For number fields: checks that number <= max.
  /// - For string fields: checks that string length <= max (length).
  /// - For date/time fields: checks that date/time <= max (inclusive).
  @JsonValue('MAX')
  max,

  /// Value must match a regular expression.
  @JsonValue('PATTERN')
  pattern,
}

/// Represents a validation rule applied to a form field.
///
/// Includes the type of rule and the associated value (if any),
/// such as the min/max for length, numeric, date/time validation, or a regex string for pattern matching.
@JsonSerializable(includeIfNull: false)
class FormValidationRule {
  /// The type of validation rule to apply (required, min, max, pattern, etc).
  final FormValidationRuleType type;

  /// The rule value. Type depends on the [type]:
  /// - For [FormValidationRuleType.min] or [FormValidationRuleType.max]:
  ///   - For number fields: a number (e.g. int, double) as the minimum or maximum value.
  ///   - For string fields: an int representing the min or max string length.
  ///   - For date/time fields: an ISO 8601 string (e.g. "2024-06-11T13:00:00Z") representing the min or max date/time value.
  /// - For [FormValidationRuleType.pattern]: a regex string.
  /// - For others (like [FormValidationRuleType.required]), this can be null.
  final dynamic value;

  /// The validation error message to show if this rule fails.
  ///
  /// If null, a default error message will be used.
  final String? message;

  const FormValidationRule({required this.type, this.value, this.message});

  factory FormValidationRule.fromJson(Map<String, dynamic> json) =>
      _$FormValidationRuleFromJson(json);
  Map<String, dynamic> toJson() => _$FormValidationRuleToJson(this);
}
