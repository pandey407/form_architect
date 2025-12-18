import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/utils/string_ext.dart';

/// [TextBrick] is a form field widget for text, textarea, and password input types.
///
/// It supports:
/// - [FormBrickType.text]: Standard single-line text input
/// - [FormBrickType.textArea]: Multi-line text input
/// - [FormBrickType.password]: Obscured text input with a visibility toggle
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

  bool get _isPassword => widget.brick.type.isPasswordType;
  bool get _isTextArea => widget.brick.type.isTextAreaType;

  TextInputType get _keyboardType {
    if (_isTextArea) {
      return TextInputType.multiline;
    }
    return TextInputType.text;
  }

  int? get _maxLines => _isTextArea ? null : 1;
  int? get _minLines => _isTextArea ? 3 : null;

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
      obscureText: _isPassword && _obscurePassword,
      maxLines: _maxLines,
      minLines: _minLines,
      textInputAction: _isTextArea
          ? TextInputAction.newline
          : TextInputAction.next,
      validator: (value) => widget.brick.validate(value: value),
      valueTransformer: (value) {
        if (value == null || value.isEmpty) return null;
        if (value.isWhiteSpace) return null;
        return value;
      },
    );
  }
}
