import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/form_architect.dart';
import 'package:form_architect/src/models/form_element.dart';
import 'package:form_architect/src/widgets/date_time_brick.dart';
import 'package:form_architect/src/widgets/file_brick.dart';
import 'package:form_architect/src/widgets/multi_select_dropdown_brick.dart';
import 'package:form_architect/src/widgets/numeric_brick.dart';
import 'package:form_architect/src/widgets/radio_brick.dart';
import 'package:form_architect/src/widgets/single_select_dropdown_brick.dart';
import 'package:form_architect/src/widgets/text_brick.dart';
import 'package:form_architect/src/widgets/toggle_brick.dart';

/// Widget builder for custom bricks.
/// * [context] is the BuildContext
/// * [brick] is the field definition
typedef CustomBrickBuilder =
    Widget Function(BuildContext context, FormBrick brick);

/// Class to wrap validated form data and files separately.
class FormArchitectResult {
  /// Non-file fields (primitive data, text, etc)
  final Map<String, dynamic> fields;

  /// Files/images/videos, where value is the list of data/objects.
  final Map<String, List<String>?> files;

  const FormArchitectResult({required this.fields, required this.files});
}

/// Main builder widget that constructs a complete form from JSON configuration.
/// This widget handles parsing JSON, rendering the form layout, and managing form state.
///
/// To provide custom bricks, provide the [customBricks] mapping.
/// Example:
/// ```dart
/// FormArchitect(
///   json: myJson,
///   customBricks: {
///     FormBrickType.text: (ctx, brick) => CustomTextBrick(brick),
///     FormBrickType.date: (ctx, brick) => CustomDateBrick(brick: brick),
///   }
/// )
/// ```
class FormArchitect extends StatefulWidget {
  /// JSON string or Map containing the form configuration
  final dynamic json;

  /// Padding around the form
  final EdgeInsets? padding;

  /// Optional: map of custom brick renderers by FormBrickType
  /// If a builder exists for a type, it will be used to render that brick type.
  final Map<FormBrickType, CustomBrickBuilder>? customBricks;

  const FormArchitect({
    super.key,
    required this.json,
    this.padding,
    this.customBricks,
  });

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

  /// Validates the form.
  /// If valid, returns a FormArchitectResult containing:
  ///   - fields: all non-file field values
  ///   - files: a map of all file/image/video fields and their values
  /// Returns `null` if validation fails.
  FormArchitectResult? validateBricks() {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) return null;
    final value = _formKey.currentState?.value ?? {};

    final bricks = _collectBricks(_formLayout);

    final filesMap = <String, List<String>?>{};
    final dataMap = <String, dynamic>{};

    for (final brick in bricks) {
      final k = brick.key;
      final v = value[k];
      if (brick.type.isFileType) {
        filesMap[k] = v as List<String>?;
      } else {
        dataMap[k] = v;
      }
    }
    return FormArchitectResult(fields: dataMap, files: filesMap);
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

  /// Collects all FormBrick elements (recursively) in the layout.
  List<FormBrick> _collectBricks(FormElement el) {
    if (el is FormBrick) {
      return [el];
    }
    if (el is FormMasonry) {
      return el.children.expand(_collectBricks).toList();
    }
    return [];
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
    // If a custom brick builder is provided for this type, use it
    final customBricks = widget.customBricks;
    if (customBricks != null && customBricks.containsKey(brick.type)) {
      return customBricks[brick.type]!(context, brick);
    }

    switch (brick.type) {
      case FormBrickType.text:
      case FormBrickType.password:
      case FormBrickType.textArea:
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
