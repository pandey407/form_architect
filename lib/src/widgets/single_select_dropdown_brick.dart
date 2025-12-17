import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/utils/custom_dropdown_theme_ext.dart';

/// A form field widget for selecting a single value from a dropdown.
///
/// [SingleSelectDropdownBrick] renders a dropdown menu using the options provided by the [FormBrick].
/// The list of options is filtered via search. The selection is handled via [CustomDropdown]'s
/// searchRequest constructor, enabling filtering on search input.
///
/// The selected value is available via the associated [FormBrick.value]. Widget can be enabled or
/// disabled via [FormBrick.isEnabled]. The generic type [T] denotes the type of the selectable values.
///
/// Example:
/// ```dart
/// SingleSelectDropdownBrick<String>(
///   brick: FormBrick<String>(
///     key: 'favorite_pet',
///     label: 'Favorite Pet',
///     hint: 'Choose one',
///     type: FormBrickType.singleSelectdropdown,
///     value: 'dog',
///     options: [
///       FormBrickOption(value: 'dog', label: 'Dog'),
///       FormBrickOption(value: 'cat', label: 'Cat'),
///     ],
///   ),
/// )
/// ```
class SingleSelectDropdownBrick<T> extends StatefulWidget {
  /// Creates a [SingleSelectDropdownBrick] for a [FormBrick].
  const SingleSelectDropdownBrick({super.key, required this.brick});

  /// The [FormBrick] providing value, options, and configuration.
  final FormBrick<T> brick;

  @override
  State<SingleSelectDropdownBrick<T>> createState() =>
      _SingleSelectDropdownBrickState<T>();
}

/// State for [SingleSelectDropdownBrick]. Manages current selection and available options.
class _SingleSelectDropdownBrickState<T>
    extends State<SingleSelectDropdownBrick<T>> {
  /// Holds the initially selected value.
  late T? initialValue;

  /// List of available options.
  late List<FormBrickOption<T>> options;

  @override
  void initState() {
    super.initState();
    initialValue = widget.brick.value;
    options = widget.brick.options ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      enabled: widget.brick.isEnabled,
      validator: (e) {
        return "Error";
      },
      builder: (FormFieldState<T> field) {
        return EmptyInputDecorator(
          child: CustomDropdown<FormBrickOption<T>>.searchRequest(
            futureRequest: (query) async {
              return options
                  .where(
                    (e) => e.label.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList();
            },

            decoration: Theme.of(context).customDropdownDecoration,
            validator: (e) {
              return "Error";
            },

            /// Hint text for dropdown search/display.
            hintText: widget.brick.hint,

            /// The item initially selected (if any).
            initialItem: options.firstWhereOrNull(
              (e) => e.value == initialValue,
            ),

            /// The list of all available options.
            items: options,

            /// Builds a widget for each item in the dropdown list.
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              return Text(item.label);
            },

            /// Builds the dropdown's header; how the selected item appears in the field.
            headerBuilder: (context, selectedItem, enabled) {
              return Text(selectedItem.label);
            },

            /// Whether the dropdown is enabled for interaction.
            enabled: widget.brick.isEnabled,
            validateOnChange: true,
            hideSelectedFieldWhenExpanded: true,
            closeDropDownOnClearFilterSearch: true,

            /// Handles value selection and updates form state.
            onChanged: (FormBrickOption<T>? selectedOption) {
              if (selectedOption == null) return;
              final selectedValue = selectedOption.value;
              setState(() {
                initialValue = selectedValue;
                field.didChange(selectedValue);
              });
            },
          ),
        );
      },
    );
  }
}
