import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/utils/text_formatter.dart';

/// A versatile text input widget that handles text, textarea, password, and number input types.
///
/// This widget adapts its behavior based on the [FormBrickType]:
/// - [FormBrickType.text]: Standard single-line text input
/// - [FormBrickType.textArea]: Multi-line text input
/// - [FormBrickType.password]: Obscured text input with visibility toggle
/// - [FormBrickType.integer]: Integer input with keyboard restrictions
/// - [FormBrickType.float]: Float type input with keyboard restrictions

class TextBrick extends StatefulWidget {
  /// The FormBrick configuration for this text field
  final FormBrick brick;

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
    _controller = TextEditingController(text: widget.brick.value ?? '');
    _focusNode = FocusNode();
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

  /// Returns the maximum number of lines allowed for the TextFormField.
  /// Returns `null` for text areas (unlimited lines), otherwise returns 1 for single-line input.
  int? get _maxLines {
    if (_isTextArea) {
      return null;
    }
    return 1;
  }

  /// Returns the minimum number of lines for the TextFormField.
  /// Returns 3 for text areas (making them taller initially), otherwise returns `null`.
  int? get _minLines {
    if (_isTextArea) {
      return 3;
    }
    return null;
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
    );
  }
}
