import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

class MultiSelectDropdownBrick<T> extends StatefulWidget {
  const MultiSelectDropdownBrick({super.key, required this.brick});
  final FormBrick<T> brick;

  @override
  State<MultiSelectDropdownBrick<T>> createState() =>
      _MultiSelectDropdownBrickState<T>();
}

class _MultiSelectDropdownBrickState<T>
    extends State<MultiSelectDropdownBrick<T>> {
  late List<FormBrickOption<T>>? initialSelectedOptions;
  late List<T> initialValue;
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
          hintText: widget.brick.hint,
          initialItems: initialSelectedOptions,
          items: options,
          listItemBuilder: (context, item, isSelected, onItemSelect) {
            return Text(item.label);
          },
          futureRequest: (query) async {
            return options
                .where(
                  (e) => e.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
          },
          headerListBuilder: (context, selectedItems, enabled) {
            return Text(selectedItems.map((e) => e.label).join(', '));
          },
          enabled: widget.brick.isEnabled,
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
