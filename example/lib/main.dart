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

  // Demo JSON for FormMasonry (a row/column form system)
  static const Map<String, dynamic> demoFormJson = {
    "type": "COL",
    "children": [
      {
        "type": "TEXT",
        "key": "name",
        "label": "Name",
        "hint": "Enter your name",
      },
      {
        "type": "TEXT",
        "key": "email",
        "label": "Email",
        "hint": "Enter your email address",
      },
      {
        "type": "PASSWORD",
        "key": "password",
        "label": "Password",
        "hint": "Enter a password",
      },
      {
        "type": "DROPDOWN",
        "key": "role",
        "label": "Role",
        "options": [
          {"value": "user", "label": "User"},
          {"value": "admin", "label": "Admin"},
        ],
      },
      {"type": "CHECKBOX", "key": "accept", "label": "I accept the terms"},
    ],
  };

  // This will hold field values as the user fills the form
  Map<String, dynamic> formValues = {};

  // Store the parsed FormMasonry here
  late final FormMasonry formRoot;

  @override
  void initState() {
    super.initState();
    // Parse FormMasonry from JSON only once in initState
    formRoot = FormMasonry.fromJson(demoFormJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              ElevatedButton(
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
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
