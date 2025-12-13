import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';

class ToggleBrick extends StatefulWidget {
  const ToggleBrick({super.key, required this.brick});
  final FormBrick<bool> brick;

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
