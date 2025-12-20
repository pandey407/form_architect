import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/form_architect.dart';
import 'package:form_architect/src/models/form_element.dart';
import 'package:form_architect/src/widgets/numeric_brick.dart';

/// Main builder widget that constructs a complete form from JSON configuration.
///
/// This widget handles parsing JSON, rendering the form layout, and managing form state.
class FormArchitect extends StatefulWidget {
  /// JSON string or Map containing the form configuration
  final dynamic json;

  /// Padding around the form
  final EdgeInsets? padding;

  const FormArchitect({super.key, required this.json, this.padding});

  @override
  State<FormArchitect> createState() => FormArchitectState();
}

class FormArchitectState extends State<FormArchitect> {
  late FormMasonry _formLayout;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _loadFormFromJson();
  }

  Map<String, dynamic>? validateBricks() {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    debugPrint(isValid.toString());
    // if (!isValid) return null;
    final value = _formKey.currentState?.value;
    return value;
  }

  void _loadFormFromJson() {
    try {
      Map<String, dynamic> jsonMap;

      if (widget.json is String) {
        jsonMap = json.decode(widget.json) as Map<String, dynamic>;
      } else if (widget.json is Map<String, dynamic>) {
        jsonMap = widget.json;
      } else {
        throw ArgumentError(
          'json must be either a String or Map<String, dynamic>',
        );
      }

      _formLayout = FormMasonry.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error parsing form JSON: $e');
      rethrow;
    }
  }

  Widget _buildBrick(FormElement element) {
    if (element is FormMasonry) {
      return _buildMasonry(element);
    } else if (element is FormBrick) {
      return _buildFormBrick(element);
    }
    return SizedBox.shrink();
  }

  Widget _buildMasonry(FormMasonry masonry) {
    final children = masonry.children.map((child) {
      final widget = _buildBrick(child);
      if (child.flex != null && masonry.type == FormMasonryType.row) {
        return Expanded(flex: child.flex!, child: widget);
      }
      return widget;
    }).toList();

    if (masonry.type == FormMasonryType.row) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _addSpacing(children, masonry.spacing, isRow: true),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _addSpacing(children, masonry.spacing, isRow: false),
      );
    }
  }

  List<Widget> _addSpacing(
    List<Widget> children,
    double? spacing, {
    required bool isRow,
  }) {
    if (spacing == null || spacing == 0 || children.isEmpty) {
      return children;
    }

    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          isRow ? SizedBox(width: spacing) : SizedBox(height: spacing),
        );
      }
    }
    return spacedChildren;
  }

  Widget _buildFormBrick(FormBrick brick) {
    switch (brick.type) {
      case FormBrickType.text:
      case FormBrickType.textArea:
      case FormBrickType.password:
        return TextBrick(brick: brick);

      case FormBrickType.integer:
      case FormBrickType.float:
        return NumericBrick(brick: brick);

      case FormBrickType.radio:
        return RadioBrick(brick: brick);

      case FormBrickType.toggle:
        return ToggleBrick(brick: brick);

      case FormBrickType.singleSelectdropdown:
        return SingleSelectDropdownBrick(brick: brick);

      case FormBrickType.multiSelectDropdown:
        return MultiSelectDropdownBrick(brick: brick);

      case FormBrickType.date:
      case FormBrickType.time:
      case FormBrickType.dateTime:
        return DateTimeBrick(brick: brick);

      case FormBrickType.image:
      case FormBrickType.video:
      case FormBrickType.file:
        return FileBrick(brick: brick);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: SingleChildScrollView(
        padding: widget.padding ?? EdgeInsets.all(16),
        child: _buildMasonry(_formLayout),
      ),
    );
  }
}
