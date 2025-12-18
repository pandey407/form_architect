import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/utils/form_validation_helper.dart';
import 'package:form_architect/src/widgets/brick_error.dart';
import 'package:form_architect/src/widgets/external_brick_label.dart';

/// [RadioBrick] is a form field widget for selecting a single value from a group of options using radio buttons.
///
/// It renders the set of provided options as a horizontal or wrapped list of radio buttons, using the
/// [FormBrick.options] for configuration. The currently selected value is held in [FormBrick.value].
///
/// The widget is enabled/disabled by [FormBrick.isEnabled]. Each option can also be disabled at the option level.
/// When a radio button is selected, its value is set into the form field and triggers a rebuild.
///
/// Type parameter [T] denotes the type of the option values.
///
/// Example:
/// ```dart
/// RadioBrick<String>(
///   brick: FormBrick<String>(
///     key: 'favorite_animal',
///     label: 'Favorite Animal',
///     type: FormBrickType.radio,
///     value: 'cat',
///     options: [
///       FormBrickOption(value: 'dog', label: 'Dog'),
///       FormBrickOption(value: 'cat', label: 'Cat'),
///     ],
///   ),
/// )
/// ```
class RadioBrick<T> extends StatefulWidget {
  /// Creates a [RadioBrick] that displays a group of radio buttons for a [FormBrick].
  const RadioBrick({super.key, required this.brick});

  /// The [FormBrick] definition, including value, options, key, etc.
  final FormBrick<T> brick;

  @override
  State<RadioBrick<T>> createState() => _RadioBrickState<T>();
}

class _RadioBrickState<T> extends State<RadioBrick<T>> {
  T? groupValue;
  @override
  void initState() {
    super.initState();
    groupValue = widget.brick.value;
  }

  /// Validates the radio selection using the brick's validation rules.
  String? _validateInput(T? value) {
    return FormValidationHelper.validate(value, widget.brick);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.brick.options;
    if (options == null) return const SizedBox.shrink();
    return FormField<T>(
      initialValue: widget.brick.value,
      enabled: widget.brick.isEnabled,
      autovalidateMode: AutovalidateMode.disabled,
      validator: widget.brick.hasValidation ? _validateInput : null,
      builder: (FormFieldState<T> field) {
        return BrickError(
          field: field,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrickLabel(brick: widget.brick),
              RadioGroup(
                groupValue: field.value,
                onChanged: (T? value) {
                  if (value == null) return;
                  if (!widget.brick.isEnabled) return;
                  field.didChange(value);
                  setState(() {
                    groupValue = value;
                  });
                },
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((option) {
                    return _RadioOption<T>(
                      groupValue: field.value,
                      option: option,
                      onChanged: widget.brick.isEnabled && !(option.disabled)
                          ? (value) {
                              field.didChange(value);
                              setState(() {
                                groupValue = value;
                              });
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single radio option widget for use in radio button groups tied to a [FormBrick].
///
/// This widget displays the radio button alongside its label and handles tap/click events.
/// It uses the [option] for display and value, and compares it against [groupValue]
/// to determine selection state.
///
/// When tapped, [onChanged] is called with the option's value if it is not disabled.
///
/// Type parameter [T] denotes the type of the value being selected.
class _RadioOption<T> extends StatelessWidget {
  /// Creates a [_RadioOption] widget.
  ///
  /// [option] must not be null. [onChanged] is called when the user selects this option.
  const _RadioOption({
    super.key,
    required this.groupValue,
    required this.option,
    required this.onChanged,
  });

  /// The option being rendered, which includes the value, label, and disabled state.
  final FormBrickOption<T> option;

  /// The value currently selected in the group.
  final T? groupValue;

  /// Called when the radio option is selected, if it is not disabled.
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = option.disabled || onChanged == null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled
          ? null
          : () {
              onChanged?.call(option.value);
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>.adaptive(value: option.value),
          const SizedBox(width: 6),
          Flexible(child: Text(option.label)),
        ],
      ),
    );
  }
}
