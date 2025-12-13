import 'package:flutter/material.dart';
import 'package:form_architect/form_architect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Architect From JSON Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Form Architect Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// A simple widget to render a "FormArchitect" form from JSON.
class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  // This will hold field values as the user fills the form
  Map<String, dynamic> formValues = {};

  // Reusable options for dropdown and radio bricks
  final List<FormBrickOption<String>> animalOptions = <String>[
    "Dog",
    "Cat",
    "Cow",
    "Crow",
    "Snake",
    "Pig",
    "Ox",
  ].map((e) => FormBrickOption(value: e.toLowerCase(), label: e)).toList();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Form Data"),
              content: Text(
                formValues.entries
                    .map((e) => "${e.key}: ${e.value}")
                    .join("\n"),
              ),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
        child: Text("Submit"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextBrick(
                brick: FormBrick(
                  key: 'name',
                  type: FormBrickType.text,
                  label: "Name",
                  hint: "Enter your name",
                ),
              ),
              SizedBox(height: 20),
              RadioBrick(
                brick: FormBrick(
                  key: 'radio',
                  type: FormBrickType.radio,
                  value: "dog",
                  options: animalOptions,
                ),
              ),
              ToggleBrick(
                brick: FormBrick<bool>(
                  key: 'accepted_terms',
                  type: FormBrickType.toggle,
                  label: 'Accept Terms & Conditions',
                  value: false,
                ),
              ),
              SizedBox(height: 20),
              SingleSelectDropdownBrick(
                brick: FormBrick<String>(
                  key: 'single-select',
                  hint: "Select one animal",
                  type: FormBrickType.singleSelectdropdown,
                  options: animalOptions,
                ),
              ),
              SizedBox(height: 20),
              MultiSelectDropdownBrick(
                brick: FormBrick<String>(
                  key: 'multi-select',
                  hint: "Select multiple animals",
                  type: FormBrickType.singleSelectdropdown,
                  options: animalOptions,
                  values: ['cow', 'cat'],
                ),
              ),
              SizedBox(height: 20),
              DateTimeBrick(
                brick: FormBrick(
                  key: 'date',
                  type: FormBrickType.dateTime,
                  label: 'Select Date',
                  value: DateTime.now(),
                  range: [
                    DateTime.now().subtract(Duration(days: 365)),
                    DateTime.now().add(Duration(days: 365)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
