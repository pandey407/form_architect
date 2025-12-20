import 'package:form_architect/src/models/form_element.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/form_validation_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'form_brick.g.dart';

///
/// Each [FormBrickType] value corresponds to a minimal form component.
/// These values determine the type and behavior of a form field.
///
/// This enum is typically used for serialization and dynamic form construction.
enum FormBrickType {
  /// A standard single-line text input field.
  @JsonValue('TEXT')
  text,

  /// A multi-line text input area.
  @JsonValue('TEXTAREA')
  textArea,

  /// A field for entering passwords (input is obscured).
  @JsonValue('PASSWORD')
  password,

  /// A number input field for floating point numerical values.
  @JsonValue('FLOAT')
  float,

  /// A number input field for integer values.
  @JsonValue('INTEGER')
  integer,

  /// A single-select radio button field.
  @JsonValue('RADIO')
  radio,

  /// A toggle (switch) field, typically for boolean input.
  @JsonValue('TOGGLE')
  toggle,

  /// A single-select dropdown field.
  @JsonValue('SINGLE_SELECT_DROPDOWN')
  singleSelectdropdown,

  /// A multi-select dropdown field.
  @JsonValue('MULTI_SELECT_DROPDOWN')
  multiSelectDropdown,

  /// A date selector field.
  @JsonValue('DATE')
  date,

  /// A time selector field.
  @JsonValue('TIME')
  time,

  /// A field for selecting both date and time.
  @JsonValue('DATE_TIME')
  dateTime,

  /// A field for images content
  @JsonValue('IMAGE')
  image,

  /// A field for videos
  @JsonValue('VIDEO')
  video,

  /// A field for other files (other than image and video)
  @JsonValue('FILE')
  file,
}

extension FormBrickTypeX on FormBrickType {
  /// Returns true if the [FormBrickType] represents a text field (text or textArea).
  bool get isTextBrickType => [
    FormBrickType.text,
    FormBrickType.password,
    FormBrickType.textArea,
  ].contains(this);

  /// Returns true if the [FormBrickType] represents a password field.
  bool get isPasswordType => this == FormBrickType.password;

  /// Returns true if the [FormBrickType] represents a text area field.
  bool get isTextAreaType => this == FormBrickType.textArea;

  /// Returns true if the [FormBrickType] represents a numeric field (integer or float).
  bool get isNumericBrickType =>
      [FormBrickType.integer, FormBrickType.float].contains(this);

  /// Returns true if the [FormBrickType] represents an integer field.
  bool get isIntegerType => this == FormBrickType.integer;

  /// Returns true if the [FormBrickType] represents a float (decimal) field.
  bool get isFloatType => this == FormBrickType.float;

  /// Returns true if this [FormBrickType] is a multi-value field type—
  /// including multi-select dropdown, file, image, or video (all of which
  /// can represent multiple item selection in the UI).
  bool get isMultiValueType => [
    FormBrickType.multiSelectDropdown,
    FormBrickType.file,
    FormBrickType.image,
    FormBrickType.video,
  ].contains(this);

  /// Returns true if the [FormBrickType] represents a date/time field (date, dateTime, or time).
  bool get isDateTimeType => [
    FormBrickType.date,
    FormBrickType.dateTime,
    FormBrickType.time,
  ].contains(this);
}

/// A [FormBrick] configures how a single [FormBrickType] should be built and rendered.
///
/// Each [FormBrick] represents the complete specification for a form field,
/// including its type, labels, validation, and available options.
///
/// The type parameter [T] represents the data type of the field's value.
@JsonSerializable(genericArgumentFactories: true, includeIfNull: false)
class FormBrick<T> extends FormElement {
  /// Unique identifier for the form field, used as the key in form data.
  final String key;

  /// The type of form brick to build.
  final FormBrickType type;

  /// Optional Display label shown to the user above the field.
  final String? label;

  /// Optional hint text providing additional context or guidance.
  final String? hint;

  /// Default or initial value for the field.
  final T? value;

  /// The selected values for multi-select fields.
  ///
  /// Only used for [FormBrickType.multiSelectDropdown] to hold the selected values.
  final List<T>? values;

  /// List of options for selection-type bricks (radio, dropdown, multiSelect, etc.).
  ///
  /// Null for non-selection bricks like text, date, etc.
  final List<FormBrickOption<T>>? options;

  /// List of validation rules for the form brick.
  ///
  /// If null or empty, no validation is applied.
  final List<FormValidationRule>? validation;

  /// Whether this form field is enabled (interactive).
  ///
  /// If `false`, the field will be disabled and the user cannot interact with it.
  /// Defaults to `true` if not specified.
  final bool isEnabled;

  const FormBrick({
    required this.key,
    required this.type,
    this.label,
    this.hint,
    this.value,
    this.values,
    this.options,
    this.validation,
    this.isEnabled = true,
    super.flex,
  });

  factory FormBrick.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$FormBrickFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$FormBrickToJson(this, toJsonT);

  /// Checks if this brick has a required validation rule.
  bool get isRequired {
    final validationRules = validation;
    if (validationRules == null || validationRules.isEmpty) {
      return false;
    }
    return validationRules.any(
      (rule) => rule.type == FormValidationRuleType.required,
    );
  }

  /// Validates a value against the brick's validation rules.
  ///
  /// Automatically determines validation logic based on the brick type.
  /// Returns the error message if validation fails, null otherwise.
  ///
  /// [value] - The value to validate (can be any type E)
  String? validate<E>({E? value, List<E>? values}) {
    final validationRules = validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    // First check required validation (applies to all field types)
    final requiredError = FormValidationHelper.validateRequired(
      value: value,
      values: values,
      brick: this,
    );
    if (requiredError != null) {
      return requiredError;
    }

    // For string-based fields, check min/max/pattern validations
    if (type.isTextBrickType) {
      return FormValidationHelper.validateTextRules(value, this);
    }

    // For numeric-based fields, check min/max validations
    if (type.isNumericBrickType) {
      return FormValidationHelper.validateNumericRules(value, this);
    }

    // For multi-select fields, check validations such as min, max, and allowed file extensions
    if (type.isMultiValueType) {
      return FormValidationHelper.validateMultiValueRules(values, this);
    }

    // For datetime-based fields, check min/max validations
    if (type.isDateTimeType) {
      return FormValidationHelper.validateDateTimeRules(value, this);
    }
    // For selection fields (radio, dropdown), only required validation applies
    // Other validation types don't apply to selection fields
    return null;
  }
}

/// Represents a single option in a selection-type FormBrickType.
///
/// The type parameter [T] represents the data type of the option's value.
@JsonSerializable(genericArgumentFactories: true, includeIfNull: false)
class FormBrickOption<T> {
  /// The value to be stored when this option is selected.
  final T value;

  /// Display label shown to the user for this option.
  final String label;

  /// Whether this option is disabled.
  final bool disabled;

  const FormBrickOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });

  factory FormBrickOption.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$FormBrickOptionFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$FormBrickOptionToJson(this, toJsonT);
}
