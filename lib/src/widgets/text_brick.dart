import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/models/form_validation_rule.dart';
import 'package:form_architect/src/utils/string_ext.dart';
import 'package:form_architect/src/utils/text_formatter.dart';

/// [TextBrick] is a form field widget for text, textarea, password, and number input types.
///
/// It adapts its behavior and appearance based on the [FormBrickType] of the given [FormBrick], supporting:
/// - [FormBrickType.text]: Standard single-line text input
/// - [FormBrickType.textArea]: Multi-line text input
/// - [FormBrickType.password]: Obscured text input with a visibility toggle
/// - [FormBrickType.integer]: Integer input with numeric keyboard and restrictions
/// - [FormBrickType.float]: Floating-point number input with numeric keyboard and restrictions
///
/// The widget is enabled/disabled via [FormBrick.isEnabled]. Labels and hints are displayed via the configuration.
/// Field value changes are handled by the widget using a [TextEditingController].
///
/// Example usage:
/// ```dart
/// TextBrick(
///   brick: FormBrick(
///     key: 'description',
///     label: 'Description',
///     type: FormBrickType.textArea,
///     value: '',
///   ),
/// )
/// ```
class TextBrick extends StatefulWidget {
  /// The [FormBrick] definition for this text field.
  final FormBrick brick;

  /// Creates a [TextBrick] for the provided [FormBrick].
  const TextBrick({super.key, required this.brick});

  @override
  State<TextBrick> createState() => _TextBrickState();
}

class _TextBrickState extends State<TextBrick> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _valueToString(widget.brick.value),
    );
    _focusNode = FocusNode();
  }

  /// Converts the brick value to a string representation.
  /// Handles int, double, String, and null values.
  String _valueToString(dynamic value) {
    if (value == null) return '';
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is String) return value;
    return value.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isPassword => widget.brick.type == FormBrickType.password;
  bool get _isTextArea => widget.brick.type == FormBrickType.textArea;
  bool get _isIntegerNumber => widget.brick.type == FormBrickType.integer;
  bool get _isFloatingNumber => widget.brick.type == FormBrickType.float;

  TextInputType get _keyboardType {
    if (_isIntegerNumber) {
      return const TextInputType.numberWithOptions(
        decimal: false,
        signed: true,
      );
    }
    if (_isFloatingNumber) {
      return const TextInputType.numberWithOptions(decimal: true, signed: true);
    }
    if (_isTextArea) {
      return TextInputType.multiline;
    }
    return TextInputType.text;
  }

  List<TextInputFormatter>? get _inputFormatters {
    if (_isFloatingNumber) {
      return [FloatingPointInputFormatter()];
    }
    if (_isIntegerNumber) {
      return [IntegerTextInputFormatter()];
    }
    return null;
  }

  /// Returns the maximum number of lines for the input:
  /// `null` for text areas, `1` for single-line fields.
  int? get _maxLines {
    if (_isTextArea) {
      return null;
    }
    return 1;
  }

  /// Returns the minimum number of lines for the input:
  /// `3` for text areas, otherwise `null`.
  int? get _minLines {
    if (_isTextArea) {
      return 3;
    }
    return null;
  }

  /// Validates the text input using the brick's validation rules.
  String? _validateInput(String? value) {
    final validationRules = widget.brick.validation;
    if (validationRules == null || validationRules.isEmpty) {
      return null;
    }

    // Apply each validation rule
    for (final rule in validationRules) {
      switch (rule.type) {
        case FormValidationRuleType.required:
          if (value.isWhiteSpace) {
            return rule.message;
          }
          break;

        case FormValidationRuleType.min:
          if (value.isWhiteSpace) {
            // Skip min validation if field is empty (required will catch it)
            continue;
          }
          final minValue = rule.value;
          if (minValue != null && value != null) {
            if (_isIntegerNumber || _isFloatingNumber) {
              // For numeric fields, compare the numeric value
              final numValue = _isIntegerNumber
                  ? int.tryParse(value)
                  : double.tryParse(value);
              if (numValue == null) {
                // Invalid number format, skip min check (could add separate validation)
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
            if (_isIntegerNumber || _isFloatingNumber) {
              // For numeric fields, compare the numeric value
              final numValue = _isIntegerNumber
                  ? int.tryParse(value)
                  : double.tryParse(value);
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.brick.isEnabled,
      decoration: InputDecoration(
        labelText: widget.brick.label,
        hintText: widget.brick.hint,
        suffixIcon: _isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      obscureText: _isPassword && _obscurePassword,
      maxLines: _maxLines,
      minLines: _minLines,
      textInputAction: _isTextArea
          ? TextInputAction.newline
          : TextInputAction.next,
      validator:
          (widget.brick.validation != null &&
              widget.brick.validation!.isNotEmpty)
          ? _validateInput
          : null,
    );
  }
}
