import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

class SingleSelectDropdownBrick<T> extends StatefulWidget {
  const SingleSelectDropdownBrick({super.key, required this.brick});
  final FormBrick<T> brick;

  @override
  State<SingleSelectDropdownBrick<T>> createState() =>
      _SingleSelectDropdownBrickState<T>();
}

class _SingleSelectDropdownBrickState<T>
    extends State<SingleSelectDropdownBrick<T>> {
  late T? initialValue;
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
      builder: (FormFieldState<T> field) {
        return CustomDropdown<FormBrickOption<T>>.searchRequest(
          futureRequest: (query) async {
            return options
                .where(
                  (e) => e.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
          },
          hintText: widget.brick.hint,
          initialItem: options.firstWhereOrNull((e) => e.value == initialValue),
          items: options,
          listItemBuilder: (context, item, isSelected, onItemSelect) {
            return Text(item.label);
          },
          headerBuilder: (context, selectedItem, enabled) {
            return Text(selectedItem.label);
          },
          enabled: widget.brick.isEnabled,
          onChanged: (FormBrickOption<T>? selectedOption) {
            if (selectedOption == null) return;
            final selectedValue = selectedOption.value;
            setState(() {
              initialValue = selectedValue;
              field.didChange(selectedValue);
            });
          },
        );
      },
    );
  }
}
