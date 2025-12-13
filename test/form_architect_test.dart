import 'package:flutter/material.dart';
import 'package:form_architect/src/models/form_brick.dart';
import 'package:form_architect/src/models/form_masonry.dart';
import 'dart:convert';

void main() {
  // Test 1: Simple FormBrick serialization
  debugPrint('=== Test 1: Simple FormBrick ===');
  final nameBrick = FormBrick<String>(
    key: 'name',
    type: FormBrickType.text,
    label: 'Full Name',
    hint: 'Enter your full name',
    value: 'John Doe',
    flex: 6,
  );

  final nameBrickJson = nameBrick.toJson((value) => value);
  debugPrint('FormBrick JSON: $nameBrickJson');

  final restoredNameBrick = FormBrick<String>.fromJson(
    nameBrickJson,
    (json) => json as String,
  );
  debugPrint(
    'Restored: ${restoredNameBrick.key}, ${restoredNameBrick.value}\n',
  );

  // Test 2: FormBrick with options (dropdown)
  debugPrint('=== Test 2: FormBrick with Options ===');
  final countryBrick = FormBrick<String>(
    key: 'country',
    type: FormBrickType.dropdown,
    label: 'Country',
    hint: 'Select your country',
    value: 'US',
    options: [
      FormBrickOption(value: 'US', label: 'United States'),
      FormBrickOption(value: 'CA', label: 'Canada'),
      FormBrickOption(value: 'UK', label: 'United Kingdom'),
    ],
  );

  final countryBrickJson = countryBrick.toJson((value) => value);
  debugPrint('Country Brick JSON: $countryBrickJson\n');

  // Test 3: Simple FormMasonry with one brick
  debugPrint('=== Test 3: Simple FormMasonry ===');
  final simpleMasonry = FormMasonry(
    type: FormMasonryType.column,
    spacing: 16,
    children: [nameBrick],
  );

  final simpleMasonryJson = simpleMasonry.toJson();
  debugPrint('Simple Masonry JSON: $simpleMasonryJson');

  final restoredSimpleMasonry = FormMasonry.fromJson(simpleMasonryJson);
  debugPrint(
    'Restored children count: ${restoredSimpleMasonry.children.length}\n',
  );

  // Test 4: Complex nested layout
  debugPrint('=== Test 4: Complex Nested Layout ===');
  final emailBrick = FormBrick<String>(
    key: 'email',
    type: FormBrickType.text,
    label: 'Email',
    hint: 'Enter your email',
  );

  final ageBrick = FormBrick<int>(
    key: 'age',
    type: FormBrickType.integer,
    label: 'Age',
    flex: 4,
  );

  final subscribeBrick = FormBrick<bool>(
    key: 'subscribe',
    type: FormBrickType.toggle,
    label: 'Subscribe to newsletter',
    value: true,
  );

  final complexMasonry = FormMasonry(
    type: FormMasonryType.column,
    spacing: 20,
    children: [
      FormMasonry(
        type: FormMasonryType.row,
        spacing: 12,
        children: [nameBrick, ageBrick],
      ),
      emailBrick,
      countryBrick,
      subscribeBrick,
    ],
  );

  final complexJson = complexMasonry.toJson();
  debugPrint('Complex Masonry JSON:');
  debugPrint(complexJson.toString());
  debugPrint('');

  final restoredComplex = FormMasonry.fromJson(complexJson);
  debugPrint('Restored complex masonry:');
  debugPrint('- Type: ${restoredComplex.type}');
  debugPrint('- Spacing: ${restoredComplex.spacing}');
  debugPrint('- Children count: ${restoredComplex.children.length}');

  // Check nested row
  final firstChild = restoredComplex.children[0];
  if (firstChild is FormMasonry) {
    debugPrint(
      '- First child is FormMasonry with ${firstChild.children.length} children',
    );
  }

  // Check email brick
  final secondChild = restoredComplex.children[1];
  if (secondChild is FormBrick) {
    debugPrint('- Second child is FormBrick with key: ${secondChild.key}');
  }
  debugPrint('');

  // Test 5: JSON string round-trip
  debugPrint('=== Test 5: JSON String Round-trip ===');
  final jsonString = '''
  {
    "type": "COL",
    "spacing": 16,
    "children": [
      {
        "key": "username",
        "type": "TEXT",
        "label": "Username",
        "hint": "Choose a unique username"
      },
      {
        "key": "password",
        "type": "PASSWORD",
        "label": "Password"
      },
      {
        "type": "ROW",
        "spacing": 8,
        "children": [
          {
            "key": "firstName",
            "type": "TEXT",
            "label": "First Name",
            "flex": 1
          },
          {
            "key": "lastName",
            "type": "TEXT",
            "label": "Last Name",
            "flex": 1
          }
        ]
      }
    ]
  }
  ''';

  final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
  final fromJsonString = FormMasonry.fromJson(jsonMap);

  debugPrint('Parsed from JSON string:');
  debugPrint('- Type: ${fromJsonString.type}');
  debugPrint('- Children: ${fromJsonString.children.length}');

  // Convert back to JSON
  final backToJson = fromJsonString.toJson();
  final backToString = json.encode(backToJson);
  debugPrint('Back to JSON string:');
  debugPrint(backToString);
  debugPrint('');

  // Test 6: Multi-select with List values
  debugPrint('=== Test 6: Multi-select with List ===');
  final interestsBrick = FormBrick<List<String>>(
    key: 'interests',
    type: FormBrickType.multiSelect,
    label: 'Interests',
    value: ['sports', 'music'],
    options: [
      FormBrickOption(value: ['sports'], label: 'Sports'),
      FormBrickOption(value: ['music'], label: 'Music'),
      FormBrickOption(value: ['tech'], label: 'Technology'),
    ],
  );

  final interestsJson = interestsBrick.toJson((value) => value);
  debugPrint('Multi-select JSON: $interestsJson\n');

  debugPrint('=== All Tests Complete ===');
}
