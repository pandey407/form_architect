import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

/// [ToggleBrick] is a form field widget for boolean values, rendered as a toggle (switch).
///
/// It renders a [SwitchListTile.adaptive] bound to the given [FormBrick<bool>].
/// The label, current value, and enabled state are configured using the [FormBrick].
///
/// When toggled by the user, the value is updated and reported to the [FormField].
///
/// Example usage:
/// ```dart
/// ToggleBrick(
///   brick: FormBrick<bool>(
///     key: 'accepted_terms',
///     type: FormBrickType.toggle,
///     label: 'Accept Terms & Conditions',
///     value: false,
///   ),
/// )
/// ```
class ToggleBrick extends StatefulWidget {
  /// Creates a [ToggleBrick] for the given boolean [FormBrick].
  const ToggleBrick({super.key, required this.brick});

  /// The [FormBrick] definition encapsulating label, value, enabled state, etc.
  final FormBrick<bool> brick;

  @override
  State<ToggleBrick> createState() => _ToggleBrickState();
}

/// State for [ToggleBrick]. Manages the toggle value and reactivity.
class _ToggleBrickState extends State<ToggleBrick> {
  /// The currently selected boolean value.
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.brick.value ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: value,
      builder: (FormFieldState<bool> field) {
        return SwitchListTile.adaptive(
          value: value,
          onChanged: widget.brick.isEnabled
              ? (bool newValue) {
                  setState(() {
                    value = newValue;
                    field.didChange(newValue);
                  });
                }
              : null,
          title: Text(widget.brick.label ?? ""),
        );
      },
    );
  }
}
