import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/widgets/brick_error.dart';
import 'package:form_architect/src/widgets/external_brick_label.dart';

/// [ToggleBrick] is a form field widget for boolean values, rendered as a toggle (switch).
///
/// It renders a [Switch] bound to the given [FormBrick<bool>], with a [BrickLabel] expanded beside it.
///
class ToggleBrick extends StatefulWidget {
  /// Creates a [ToggleBrick] for the given boolean [FormBrick].
  const ToggleBrick({super.key, required this.brick});

  /// The [FormBrick] definition encapsulating label, value, enabled state, etc.
  final FormBrick brick;

  @override
  State<ToggleBrick> createState() => _ToggleBrickState();
}

class _ToggleBrickState extends State<ToggleBrick> {
  late bool value;

  @override
  void initState() {
    super.initState();
    value = widget.brick.value ?? false;
  }

  void _toggle(FormFieldState<bool> field) {
    if (!widget.brick.isEnabled) return;
    final newValue = !value;
    setState(() {
      value = newValue;
      field.didChange(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<bool>(
      name: widget.brick.key,
      initialValue: value,
      builder: (FormFieldState<bool> field) {
        return BrickError(
          field: field,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.brick.isEnabled ? () => _toggle(field) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: BrickLabel(brick: widget.brick)),
                  Switch(
                    value: value,
                    onChanged: widget.brick.isEnabled
                        ? (bool newValue) {
                            setState(() {
                              value = newValue;
                              field.didChange(newValue);
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
