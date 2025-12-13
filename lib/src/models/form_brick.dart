import 'package:form_architect/src/models/form_element.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
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

  /// A number input field for floating point numerical values.
  @JsonValue('FLOAT')
  float,

  /// A number input field for integer values.
  @JsonValue('INTEGER')
  integer,

  /// A field for entering passwords (input is obscured).
  @JsonValue('PASSWORD')
  password,

  /// A single-select radio button field.
  @JsonValue('RADIO')
  radio,

  /// A toggle (switch) field, typically for boolean input.
  @JsonValue('TOGGLE')
  toggle,

  /// A multi-select field, allowing selection of multiple options.
  @JsonValue('MULTISELECT')
  multiSelect,

  /// A single-select dropdown field.
  @JsonValue('DROPDOWN')
  dropdown,

  /// A multi-select dropdown field.
  @JsonValue('MULTISELECT_DROPDOWN')
  multiSelectDropdown,

  /// A date selector field.
  @JsonValue('DATE')
  date,

  /// A time selector field.
  @JsonValue('TIME')
  time,

  /// A field for selecting both date and time.
  @JsonValue('DATETIME')
  dateTime,

  /// A field for multimedia content (images, videos, etc.).
  @JsonValue('MULTIMEDIA')
  multimedia,
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
