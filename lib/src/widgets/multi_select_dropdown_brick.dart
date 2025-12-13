import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

/// A form field widget for selecting multiple values from a dropdown menu.
///
/// [MultiSelectDropdownBrick] displays a searchable, multi-select dropdown using the
/// provided options from the [FormBrick]. It leverages [CustomDropdown]'s
/// `multiSelectSearchRequest` to enable searching and selection of multiple items.
///
/// The initial selected values are taken from [FormBrick.values]. Interactions are
/// enabled or disabled via [FormBrick.isEnabled]. Generic type [T] is the type of
/// values managed/selectable.
///
/// Example:
/// ```dart
/// MultiSelectDropdownBrick<String>(
///   brick: FormBrick<String>(
///     key: 'favorite_animals',
///     label: 'Favorite Animals',
///     hint: 'Select animals',
///     type: FormBrickType.multiSelectDropdown,
///     options: [
///       FormBrickOption(value: 'dog', label: 'Dog'),
///       FormBrickOption(value: 'cat', label: 'Cat'),
///       FormBrickOption(value: 'cow', label: 'Cow'),
///     ],
///     values: ['dog', 'cat'],
///   ),
/// )
/// ```
class MultiSelectDropdownBrick<T> extends StatefulWidget {
  /// Creates a [MultiSelectDropdownBrick] for the given [FormBrick].
  const MultiSelectDropdownBrick({super.key, required this.brick});

  /// The [FormBrick] providing options, selected values, hints, and configuration.
  final FormBrick<T> brick;

  @override
  State<MultiSelectDropdownBrick<T>> createState() =>
      _MultiSelectDropdownBrickState<T>();
}

/// State for [MultiSelectDropdownBrick]. Manages selected and available options.
class _MultiSelectDropdownBrickState<T>
    extends State<MultiSelectDropdownBrick<T>> {
  /// The list of options corresponding to the currently selected values.
  late List<FormBrickOption<T>>? initialSelectedOptions;

  /// The list of initially selected values.
  late List<T> initialValue;

  /// The full set of available options.
  late List<FormBrickOption<T>> options;

  @override
  void initState() {
    super.initState();
    options = widget.brick.options ?? [];
    initialValue = widget.brick.values ?? [];
    initialSelectedOptions = options
        .where((e) => initialValue.contains(e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<T>>(
      initialValue: initialValue,
      enabled: widget.brick.isEnabled,
      builder: (FormFieldState<List<T>> field) {
        return CustomDropdown<FormBrickOption<T>>.multiSelectSearchRequest(
          /// Hint text for dropdown field and search bar.
          hintText: widget.brick.hint,

          /// The initially selected dropdown items.
          initialItems: initialSelectedOptions,

          /// All available options to select from.
          items: options,

          /// Builds each item in the dropdown list.
          listItemBuilder: (context, item, isSelected, onItemSelect) {
            return Text(item.label);
          },

          /// Asynchronously filters dropdown options based on search query.
          futureRequest: (query) async {
            return options
                .where(
                  (e) => e.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
          },

          /// How the selected items appear inside the dropdown field.
          headerListBuilder: (context, selectedItems, enabled) {
            return Text(selectedItems.map((e) => e.label).join(', '));
          },

          /// Whether the dropdown is interactive.
          enabled: widget.brick.isEnabled,

          /// Callback when the list of selected options changes.
          onListChanged: (selectedOptions) {
            if (selectedOptions.isEmpty) return;
            final selectedValues = selectedOptions.map((e) => e.value).toList();
            setState(() {
              field.didChange(selectedValues);
            });
          },
        );
      },
    );
  }
}
