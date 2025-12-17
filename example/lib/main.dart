import 'package:flutter/material.dart';
import 'package:form_architect/form_architect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Input theme configuration
    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2.0),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      labelStyle: const TextStyle(color: Colors.deepPurple),
      floatingLabelStyle: const TextStyle(
        color: Colors.deepPurple,
        fontWeight: FontWeight.bold,
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 12.0,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2.0),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: true,
    );

    return MaterialApp(
      title: 'Form Architect From JSON Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        inputDecorationTheme: inputDecorationTheme,
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

class _MyHomePageState extends State<MyHomePage> {
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> formValues = {};

  final String formJson = '''
{
  "type": "COL",
  "spacing": 16,
  "children": [
    {
      "key": "email",
      "type": "TEXT",
      "label": "Email Address",
      "hint": "Enter your email",
      "validation": [
        {"type": "REQUIRED"},
        {"type": "EMAIL"}
      ]
    },
    {
      "key": "bio",
      "type": "TEXTAREA",
      "label": "Biography",
      "hint": "Tell us about yourself"
    },
    {
      "key": "password",
      "type": "PASSWORD",
      "label": "Password",
      "hint": "Enter a secure password",
      "validation": [
        {"type": "REQUIRED"},
        {"type": "MIN", "value": 8}
      ]
    },
    {
      "type": "ROW",
      "spacing": 12,
      "children": [
        {
          "key": "age",
          "type": "INTEGER",
          "label": "Age",
          "hint": "Your age",
          "flex": 1,
          "validation": [
            {"type": "MIN", "value": 0},
            {"type": "MAX", "value": 120}
          ]
        },
        {
          "key": "height",
          "type": "FLOAT",
          "label": "Height (m)",
          "hint": "Your height in meters",
          "flex": 1
        }
      ]
    },
    {
      "key": "gender",
      "type": "RADIO",
      "label": "Gender",
      "hint": "We'll help you connect",
      "options": [
        {"value": "male", "label": "Male"},
        {"value": "female", "label": "Female"},
        {"value": "other", "label": "Other"}
      ]
    },
    {
      "key": "newsletter",
      "type": "TOGGLE",
      "label": "Subscribe to newsletter",
      "hint": "Stay update with the latest",
      "value": false
    },
    {
      "key": "country",
      "type": "SINGLE_SELECT_DROPDOWN",
      "label": "Country",
      "hint": "Select your country",
      "options": [
        {"value": "us", "label": "United States"},
        {"value": "uk", "label": "United Kingdom"},
        {"value": "ca", "label": "Canada"},
        {"value": "au", "label": "Australia"}
      ]
    },
    {
      "key": "interests",
      "type": "MULTI_SELECT_DROPDOWN",
      "label": "Interests",
      "hint": "Select your interests",
      "options": [
        {"value": "sports", "label": "Sports"},
        {"value": "music", "label": "Music"},
        {"value": "travel", "label": "Travel"},
        {"value": "reading", "label": "Reading"},
        {"value": "gaming", "label": "Gaming"}
      ]
    },
    {
      "key": "birthDate",
      "type": "DATE",
      "label": "Birth Date",
      "hint": "Select your birth date",
      "value": "1988-02-08",
      "range": ["1900-01-01", "2025-12-31"]
    },
    {
      "key": "preferredTime",
      "type": "TIME",
      "label": "Preferred Contact Time",
      "hint": "When should we contact you?"
    },
    {
      "key": "appointmentDateTime",
      "type": "DATE_TIME",
      "label": "Appointment Date & Time",
      "hint": "Select appointment date and time"
    },
    {
      "key": "profileImage",
      "type": "IMAGE",
      "label": "Profile Picture",
      "hint": "Upload your profile picture"
    },
    {
      "key": "introVideo",
      "type": "VIDEO",
      "label": "Introduction Video",
      "hint": "Upload a short intro video"
    },
    {
      "key": "resume",
      "type": "FILE",
      "label": "Resume",
      "hint": "Upload your resume (PDF)"
    }
  ]
}
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final isValid = formKey.currentState?.validate() ?? false;
          if (!isValid) return;
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
        child: Icon(Icons.check),
      ),
      body: FormArchitect(json: formJson, formKey: formKey),
    );
  }
}
