import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final formKey = GlobalKey<FormArchitectState>();
  String formJson = '';

  @override
  void initState() {
    super.initState();
    _loadFormJson();
  }

  Future<void> _loadFormJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/form.json');
      setState(() {
        formJson = jsonString;
      });
    } catch (e) {
      debugPrint('Error loading form JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final values = formKey.currentState?.validateBricks();
          if (values == null) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Form Data"),
              content: Text(
                values.entries.map((e) => "${e.key}: ${e.value}").join("\n"),
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
      body: formJson.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : FormArchitect(json: formJson, key: formKey),
    );
  }
}
