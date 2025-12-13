import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

class RadioBrick<T> extends StatefulWidget {
  const RadioBrick({super.key, required this.brick});
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

  @override
  Widget build(BuildContext context) {
    final options = widget.brick.options;
    if (options == null) return SizedBox.shrink();
    return FormField(
      initialValue: groupValue,

      autovalidateMode: AutovalidateMode.always,
      builder: (FormFieldState<T> field) {
        return RadioGroup(
          onChanged: (T? value) {
            setState(() {
              groupValue = value;
            });
          },
          child: RadioGroup<T>(
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                groupValue = value;
              });
            },
            groupValue: groupValue,
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: options.map((option) {
                return _RadioOption<T>(
                  groupValue: groupValue,
                  option: option,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                );
              }).toList(),
            ),
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
    this.groupValue,
    required this.option,
    required this.onChanged,
  });

  /// The option being rendered, which includes the value, label, and disabled state.
  final FormBrickOption<T> option;

  /// The value currently selected in the group.
  final T? groupValue;

  /// Called when the radio option is selected, if it is not disabled.
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = option.disabled;
    // The entire row (including radio and label) is tappable.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isDisabled
          ? null
          : () {
              onChanged(option.value);
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio.adaptive(value: option.value),
          const SizedBox(width: 6),
          Flexible(child: Text(option.label)),
        ],
      ),
    );
  }
}
