import 'package:flutter/material.dart';
import 'package:json_repair_flutter/json_repair_flutter.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Repair Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const JsonRepairScreen(),
    );
  }
}

class JsonRepairScreen extends StatefulWidget {
  const JsonRepairScreen({super.key});

  @override
  State<JsonRepairScreen> createState() => _JsonRepairScreenState();
}

class _JsonRepairScreenState extends State<JsonRepairScreen> {
  final TextEditingController _controller = TextEditingController();
  String _repairedJson = '';
  List<dynamic> _repairLogs = [];
  bool _loggingEnabled = true;

  // Examples of broken JSON inspired by real-world cases and the original library's tests
  final Map<String, String> brokenJsonExamples = {
    'Missing Closing Brace': '{"key": "value", "anotherKey": "anotherValue"',
    'Trailing Comma': '{"key": "value",}',
    'Unquoted Keys': '{key: "value", anotherKey: "anotherValue"}',
    'Single Quotes': "{'key': 'value'}",
    'Missing Value': '{"key": }',
    'Mixed Quotes & No Comma':
        '{\'key\': "value" "anotherKey": \'anotherValue\'}',
    'Line Comments': '''
    {
      // This is a comment
      "key": "value",
      # Another comment style
      "anotherKey": "anotherValue"
    }
    ''',
    'Incomplete String': '{"key": "this string is not closed',
    'Array with Trailing Comma': '["a", "b",]',
    'LLM Hallucination':
        'Here is the JSON you requested: {"name": "John Doe", "items": ["item1", "item2" "item3}'
  };

  void _repairAndDisplay(String jsonInput) {
    setState(() {
      _controller.text = jsonInput;
      _repairedJson = '';
      _repairLogs = [];

      try {
        final result = repairJson(
          jsonInput,
          logging: _loggingEnabled,
        );

        const encoder = JsonEncoder.withIndent('  ');

        if (_loggingEnabled && result is Map<String, dynamic>) {
          _repairedJson = encoder.convert(result['data']);
          _repairLogs = result['log'] as List<dynamic>;
        } else {
          _repairedJson = encoder.convert(result);
        }
      } catch (e) {
        _repairedJson = "Failed to repair JSON.\nError: ${e.toString()}";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Start with a default example
    _repairAndDisplay(brokenJsonExamples.values.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON Repair Flutter'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Malformed JSON:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'e.g., {key: "value",}',
              ),
              onChanged: _repairAndDisplay,
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Cases:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: brokenJsonExamples.entries.map((entry) {
                return ElevatedButton(
                  onPressed: () => _repairAndDisplay(entry.value),
                  child: Text(entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Repaired JSON Output:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text('Enable Logging'),
                    Switch(
                      value: _loggingEnabled,
                      onChanged: (value) {
                        setState(() {
                          _loggingEnabled = value;
                        });
                        // Re-run the repair with the new logging setting
                        _repairAndDisplay(_controller.text);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Text(
                _repairedJson,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            if (_loggingEnabled && _repairLogs.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Repair Logs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _repairLogs.map((log) {
                    final logMap = log as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Action: ${logMap['text']}\nContext: ...${logMap['context']}...",
                        style: TextStyle(
                            color: Colors.yellow.shade300,
                            fontFamily: 'monospace'),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
