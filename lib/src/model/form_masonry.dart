import 'package:form_architect/src/model/form_brick.dart';
import 'package:form_architect/src/model/form_element.dart';
import 'package:json_annotation/json_annotation.dart';
part 'form_masonry.g.dart';

/// Defines the available layout types for arranging form elements in a masonry container.
///
/// Each [FormMasonryType] determines how its child elements are arranged
/// in the form layout tree. This is used for responsive form layouts.
///
/// - [row]: Arranges children horizontally in a single row.
/// - [column]: Arranges children vertically in a single column.
enum FormMasonryType {
  /// Arranges children horizontally in a row.
  @JsonValue('ROW')
  row,

  /// Arranges children vertically in a column.
  @JsonValue('COL')
  column,
}

/// Defines the layout structure for organizing FormBricks in a form.
///
/// FormMasonry uses a flexible row/column system to create responsive
/// form layouts from JSON configuration.
@JsonSerializable(includeIfNull: false)
class FormMasonry extends FormElement {
  /// The type of layout container.
  final FormMasonryType type;

  /// Spacing between child elements (in logical pixels).
  final double? spacing;

  /// Child elements - can be FormBricks or nested FormMasonry layouts.
  @JsonKey(fromJson: _childrenFromJson, toJson: _childrenToJson)
  final List<FormElement> children;

  const FormMasonry({
    required this.type,
    this.spacing,
    required this.children,
    super.flex,
  });

  factory FormMasonry.fromJson(Map<String, dynamic> json) =>
      _$FormMasonryFromJson(json);

  Map<String, dynamic> toJson() => _$FormMasonryToJson(this);

  static List<FormElement> _childrenFromJson(List<dynamic> json) {
    return json.map((e) => _childFromJson(e as Map<String, dynamic>)).toList();
  }

  static FormElement _childFromJson(Map<String, dynamic> json) {
    // If it has children, it's a FormMasonry
    if (json.containsKey('children')) {
      return FormMasonry.fromJson(json);
    }
    // Otherwise it's a FormBrick
    return FormBrick.fromJson(json, (value) => value);
  }

  static List<Map<String, dynamic>> _childrenToJson(
    List<FormElement> children,
  ) {
    return children.map((e) {
      if (e is FormMasonry) {
        return e.toJson();
      } else if (e is FormBrick) {
        return e.toJson((value) => value);
      } else {
        throw UnsupportedError('Unknown FormElement type: ${e.runtimeType}');
      }
    }).toList();
  }
}
