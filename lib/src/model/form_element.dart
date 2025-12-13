/// Base class for all form layout elements.
///
/// This allows both [FormBrick] (leaf nodes) and [FormMasonry] (containers)
/// to be used interchangeably in the layout tree.
abstract class FormElement {
  /// Optional flex value for responsive width distribution.
  final int? flex;

  const FormElement({this.flex});
}
