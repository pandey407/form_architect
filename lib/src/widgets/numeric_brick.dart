import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/utils/string_ext.dart';
import 'package:form_architect/src/utils/text_formatter.dart';

/// [NumericBrick] is a form field widget for integer and floating-point number inputs.
///
/// It supports:
/// - [FormBrickType.integer]: Integer input with numeric keyboard
/// - [FormBrickType.float]: Floating-point number input with numeric keyboard
///
/// The widget emits `num` values (int or double) instead of strings.
///
/// Example usage:
/// ```dart
/// NumericBrick(
///   brick: FormBrick(
///     key: 'age',
///     label: 'Age',
///     type: FormBrickType.integer,
///     value: 25,
///   ),
/// )
/// ```
class NumericBrick extends StatefulWidget {
  /// The [FormBrick] definition for this number field.
  final FormBrick brick;

  /// Creates a [NumericBrick] for the provided [FormBrick].
  const NumericBrick({super.key, required this.brick});

  @override
  State<NumericBrick> createState() => _NumericBrickState();
}

class _NumericBrickState extends State<NumericBrick> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.brick.value?.toString() ?? '',
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isInteger => widget.brick.type.isIntegerType;
  bool get _isFloat => widget.brick.type.isFloatType;

  TextInputType get _keyboardType {
    if (_isInteger) {
      return const TextInputType.numberWithOptions(
        decimal: false,
        signed: true,
      );
    }
    return const TextInputType.numberWithOptions(decimal: true, signed: true);
  }

  List<TextInputFormatter> get _inputFormatters {
    if (_isFloat) {
      return [FloatingPointInputFormatter()];
    }
    return [IntegerTextInputFormatter()];
  }

  /// Parses a string value to a num (int or double) based on the field type.
  num? _parseValue(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.isWhiteSpace) return null;
    if (_isInteger) {
      return int.tryParse(value);
    }
    return double.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.brick.key,
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.brick.isEnabled,
      decoration: InputDecoration(
        labelText: widget.brick.label,
        hintText: widget.brick.hint,
      ),
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      textInputAction: TextInputAction.next,
      validator: (value) => widget.brick.validate(value: value),
      valueTransformer: (value) => _parseValue(value),
    );
  }
}
