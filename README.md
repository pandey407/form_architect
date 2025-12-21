# 👷‍♂️ Form Architect
**Schema in. Form out.**

Form Architect is a type-safe, schema-driven dynamic form engine for Flutter.  
It allows developers to generate complete forms from JSON definitions, while keeping type safety, validation, and data binding fully integrated.

The goal is to make dynamic forms feel as safe and predictable as hand-written Flutter forms, while remaining flexible and extensible.

## Features
- **JSON-Driven Forms:** Define complex forms using simple JSON structures
- **15+ Field Types:** Text, text area, password, numeric (integer/float), radio, toggle, dropdowns (single/multi-select), date/time pickers, and file uploads (image, video, file)
- **Built-in Validation:** Required fields, min/max constraints, pattern matching, file extension restrictions
- **Flexible Layouts:** Arrange fields in rows and columns with customizable spacing and flex properties
- **Type-Safe:** Full generic type support for form values and options
- **Extensible:** Easy to add custom validation rules and field types


## Field Types

Form Architect supports various field "bricks" in your JSON schema, with each field type supporting certain validations. Each field can have a `label` (displayed as the field's title or prompt to the user), a `hint` (provides helper text below the field for additional guidance), and a `key` (used as the unique identifier for that field in the submitted data). Fields that support choices need to specify an `options` field. Every field has the ability to list validation rules as `validations`.

Below is an overview of the available field types:

| Field Type           | Type Value (JSON)         | Description                                                |
|----------------------|--------------------------|------------------------------------------------------------|
| **Text**             | `TEXT`                   | Single-line string input                                   |
| **Text Area**        | `TEXTAREA`               | Multi-line text input                                      |
| **Password**         | `PASSWORD`               | Password entry, input obscured                             |
| **Integer**          | `INTEGER`                | Integer number input                                       |
| **Float**            | `FLOAT`                  | Floating-point number input                                |
| **Radio**            | `RADIO`                  | Single choice radio buttons                                |
| **Toggle**           | `TOGGLE`                 | True/false switch                                          |
| **Single Dropdown**  | `SINGLE_SELECT_DROPDOWN` | Single choice dropdown                                     |
| **Multi Dropdown**   | `MULTI_SELECT_DROPDOWN`  | Multiple choice dropdown                                   |
| **Date**             | `DATE`                   | Date picker; pattern = date output format                  |
| **Time**             | `TIME`                   | Time picker; pattern = time output format                  |
| **DateTime**         | `DATE_TIME`              | Date + time picker; pattern = date time output format      |
| **Image**            | `IMAGE`                  | Select images                                              |
| **Video**            | `VIDEO`                  | Select video files                                         |
| **File**             | `FILE`                   | Select custom files                                        |

**Note:**  
- Fields such as multi dropdowns, images, videos, and files return or validate against a list of items (`values`).
- All other fields use a singular `value` for validation and data access.

## Options Support

Many field types in Form Architect use **options**—that is, a fixed list of possible choices the user can select from. This is common for dropdowns and radios.

Each option in the JSON schema is defined with a `label` (user-facing text) and a `value` (the internal value submitted in form data). Options are provided as a list in the field definition under the `"options"` property.

**Example:**

```json
{
  "type": "SINGLE_SELECT_DROPDOWN",
  "key": "country",
  "label": "Country",
  "options": [
    { "label": "USA", "value": "us" },
    { "label": "Canada", "value": "ca" },
    { "label": "Mexico", "value": "mx" }
  ],
}
```

**Option Structure**

Each option object can contain:

| Property   | Type      | Required | Description                        |
|------------|-----------|----------|------------------------------------|
| `label`    | `string`  | Yes      | What the user sees                 |
| `value`    | any       | Yes      | The value returned in form output  |


**Fields with Options**

The following field types support (or require) an `"options"` property:

- `RADIO`
- `SINGLE_SELECT_DROPDOWN`
- `MULTI_SELECT_DROPDOWN`

For multi-select fields, `values` defines the pre-selected choices, where as for single select dropdown and radio fields `value` defines the selected choice.

**Example: Multi-Select Dropdown**

```json
{
  "type": "MULTI_SELECT_DROPDOWN",
  "key": "favorite_colors",
  "label": "Favorite Colors",
  "options": [
    { "label": "Red", "value": "red" },
    { "label": "Blue", "value": "blue" },
    { "label": "Green", "value": "green" },
    { "label": "Yellow", "value": "yellow" }
  ],
  "values": ["red", "blue"]
}
```

**Option Values and Form Data**

Selected option values are returned in the output map under the field's key:

- **Single-select:**  
  `"country": "us"`
- **Multi-select:**  
  `"favorite_colors": ["red", "blue"]`

**Note:** The label is *not* returned in results, only the selected value(s).


## Validations
Validation rules can be added to fields to enforce required input, restrict value ranges, ensure matching patterns, and more. Each validation is defined as an object that specifies the validation `type`, an optional `value` (when needed), and a user-friendly `message` to display on error. Multiple validations can be combined in a field's `validations` array to provide comprehensive input checks.


The table below shows which validation types are supported for each field type.  
✅ = Supported  ❌ = Not Applicable

| Field Type              | REQUIRED | MIN | MAX | PATTERN | ALLOWED_FILE_EXTENSIONS |
|-------------------------|:--------:|:---:|:---:|:-------:|:----------------------:|
| **TEXT**                |   ✅     | ✅  | ✅  |   ✅    |         ❌             |
| **TEXTAREA**            |   ✅     | ✅  | ✅  |   ✅    |         ❌             |
| **PASSWORD**            |   ✅     | ✅  | ✅  |   ✅    |         ❌             |
| **INTEGER**             |   ✅     | ✅  | ✅  |   ❌    |         ❌             |
| **FLOAT**               |   ✅     | ✅  | ✅  |   ❌    |         ❌             |
| **RADIO**               |   ✅     | ❌  | ❌  |   ❌    |         ❌             |
| **TOGGLE**            |   ✅     | ❌  | ❌  |   ❌    |         ❌             |
| **SINGLE_SELECT_DROPDOWN** | ✅  | ❌  | ❌  |   ❌    |         ❌             |
| **MULTI_SELECT_DROPDOWN** | ✅   | ✅  | ✅  |   ❌    |         ❌             |
| **DATE**                |   ✅     | ✅  | ✅  |   ✅    |         ❌             |
| **TIME**                |   ✅     | ✅  | ✅  |   ✅    |         ❌             |
| **DATE_TIME**           |   ✅     | ✅  | ✅  |   ✅    |         ❌             |
| **IMAGE**               |   ✅     | ✅  | ✅  |   ❌    |         ❌             |
| **VIDEO**               |   ✅     | ✅  | ✅  |   ❌    |         ❌             |
| **FILE**                |   ✅     | ✅  | ✅  |   ❌    |         ✅             |


See the table below for available validation types and usage examples.

| Validation | What it Does | Example JSON Rules |
|------------|--------------|-------------------|
| **REQUIRED** | Field must not be empty | `{ "type": "REQUIRED", "message": "This field is required" }` |
| **MIN** | Sets minimum constraints | **For text fields (minimum length):**<br>`{ "type": "MIN", "value": 8, "message": "Must be at least 8 characters" }`<br><br>**For numeric fields (minimum value):**<br>`{ "type": "MIN", "value": 18, "message": "Must be at least 18" }`<br><br>**For multi-select/file fields (minimum selections):**<br>`{ "type": "MIN", "value": 2, "message": "Select at least 2 items" }`<br><br>**For date/time fields (earliest date):**<br>`{ "type": "MIN", "value": "2024-01-01", "message": "Date must be after Jan 1, 2024" }` |
| **MAX** | Sets maximum constraints | **For text fields (maximum length):**<br>`{ "type": "MAX", "value": 100, "message": "Must be 100 characters or less" }`<br><br>**For numeric fields (maximum value):**<br>`{ "type": "MAX", "value": 65, "message": "Must be 65 or less" }`<br><br>**For multi-select/file fields (maximum selections):**<br>`{ "type": "MAX", "value": 5, "message": "Select up to 5 items" }`<br><br>**For date/time fields (latest date):**<br>`{ "type": "MAX", "value": "2025-12-31", "message": "Date must be before Dec 31, 2025" }` |
| **PATTERN** | Validates regex pattern (text) or specifies output format (date/time) | **For text fields (regex validation):**<br>`{ "type": "PATTERN", "value": "^[a-zA-Z]+$", "message": "Only letters allowed" }`<br><br>**Email pattern:**<br>`{ "type": "PATTERN", "value": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", "message": "Invalid email" }`<br><br>**Password pattern:**<br>`{ "type": "PATTERN", "value": "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$", "message": "Must contain uppercase, lowercase, number, and special character" }`<br><br>**For date/time fields (output format):**<br>`{ "type": "PATTERN", "value": "yyyy-MM-dd", "message": "Date format must be YYYY-MM-DD" }` |
| **ALLOWED_FILE_EXTENSIONS** | Restricts file uploads to specific extensions | `{ "type": "ALLOWED_FILE_EXTENSIONS", "value": ["pdf", "doc", "docx"], "message": "Only PDF and Word documents allowed" }` |


#### Notes

- **Pattern validation** for `DATE`, `TIME`, `DATE_TIME` is used to enforce a specific output format.
- **Min/Max** for file/image/video types refers to number of files uploaded (not file size).
- **Allowed Extensions** restricts file uploads to specific extensions (e.g. pdf, png).

For a real-world configuration, see the [example schema](example/assets/form.json).

## Data Binding

Form Architect provides easy access to validated form field values and file uploads with the `validateBricks()` method on the form's state. This function returns a `FormArchitectResult` with two maps:

- `fields`: A `Map<String, dynamic>` containing all non-file field values.
- `files`: A `Map<String, dynamic>` containing file/image/video field values, where values are file paths or URIs.

You can use these results to serialize, save, or bind form data directly to your APIs and databases.

**Example:**

```dart
final result = formKey.currentState?.validateBricks();
if (result != null) {
  // result.fields contains regular fields (strings, numbers, etc)
  // result.files contains file/image/video fields (as file paths/URIs)
  final json = jsonEncode(result.fields);
  print(json);
}
```

The returned `fields` map structure reflects your form definition.

**Sample returned values:**  
(For fields, not including files/images/videos)

```json
{
  "email": "test@example.com",
  "full_name": "Ada Lovelace",
  "bio": "This is my short biography.",
  "age": 25,
  "height": 170.0,
  "gender": "female",
  "country": "us",
  "interests": ["sports", "music"],
  "birth_date": "2000-01-01",
  "preferred_time": "13:00",
  "appointment_date_time": "2025-10-21T09:30",
  "newsletter": false
}
```

And in `files` you might have:

```json
{
  "receipts": [
    "receipt1.png",
    "receipt2.png"
  ],
  "resume": ["resume.pdf"],
  "intro_video": ["intro.mp4"]
}
```

Use these maps to easily integrate with your backend or any data persistence layer.

> **Note:**  
> For all file, image, or video fields (such as "resume", "receipts", or "intro_video"), the values in the `files` map returned by `validateBricks()` are **always a List of storage paths or URIs**, even if only one file is selected.  
>
> To upload files to a backend, you must convert each path in these lists into a `MultipartFile` and include them in a multipart API request.

> **Example using [`dio`](https://pub.dev/packages/dio) in Dart:**  
>
> ```dart
> import 'package:dio/dio.dart';
> import 'dart:io';
>
> final result = formKey.currentState?.validateBricks();
> if (result != null) {
>   final dio = Dio();
>   final fields = result.fields;
>   final files = result.files;
>
>   final formData = FormData.fromMap(fields);
>
>   // Add all file/image/video fields (each value is always a List)
>   Future<void> addFilesToFormData(Map<String, dynamic> files) async {
>     for (final entry in files.entries) {
>       final key = entry.key;
>       final List fileList = entry.value as List;
>       for (final path in fileList) {
>         formData.files.add(MapEntry(
>           key,
>           await MultipartFile.fromFile(path, filename: path.split('/').last),
>         ));
>       }
>     }
>   }
>
>   await addFilesToFormData(files);
>
>   final response = await dio.post(
>     'https://example.com/api/upload',
>     data: formData,
>     options: Options(contentType: 'multipart/form-data'),
>   );
>   // Handle response as needed
> }
> ```
>


