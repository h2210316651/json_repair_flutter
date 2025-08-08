# `json_repair` for Dart & Flutter: Effortlessly Fix Broken JSON

[![pub package](https://img.shields.io/pub/v/json_repair_flutter.svg)](https://pub.dev/packages/json_repair_flutter)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)

A powerful Dart and Flutter package designed to repair malformed JSON strings. It intelligently fixes and decodes messy JSON data often received from APIs or user input, drawing inspiration from the robust Python `json_repair` module.

This library is your go-to solution for handling JSON that doesn't quite conform to the standards, saving you from parsing errors and making your applications more resilient.

## Key Features

- **Handles Common JSON Errors**: Automatically corrects a wide range of issues, including:
    - **Unquoted Object Keys**: Adds missing quotes to keys (e.g., `{name: "John"}` → `{"name": "John"}`).
    - **Incorrect Quotes**: Converts single quotes to the required double quotes.
    - **Trailing Commas**: Removes invalid trailing commas from objects and arrays.
    - **Missing Value Quotes**: Encloses string values in quotes where needed.
    - **Unclosed Structures**: Safely closes dangling braces and brackets.
    - **Comment Removal**: Strips out JavaScript-style line and block comments.
    - **Faulty Escaping**: Corrects improper quote escaping.
    - **Multiline Strings**: Normalizes multiline strings to be parsable.
- **Extensible API**: Provides the flexibility to introduce or customize your own repair strategies for unique edge cases.
- **Safe and Simple Decoding**: Directly decode the repaired JSON into Dart objects (`Map` or `List`) with convenient functions.
- **Cross-Platform**: Works seamlessly in Flutter, pure Dart, server-side applications, and on the web.

## Quick Start

Get your JSON repaired in just a few lines of code.

### 1. Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  json_repair_flutter: ^1.0.0
```

Then, fetch the packages from your terminal:

```sh
flutter pub get
```

### 2. Basic Usage

Repairing and decoding JSON is straightforward:

```dart
import 'package:json_repair_flutter/json_repair_flutter.dart';

void main() {
  const malformedJson = '{name: "John", age: 30,}';

  // Just repair the string
  final repairedJson = repairJson(malformedJson);
  print(repairedJson); // Output: {"name": "John", "age": 30}

  // Repair and decode into a Dart object
  final decodedData = repairJsonAndDecode(malformedJson);
  if (decodedData is Map<String, dynamic>) {
    print(decodedData['name']); // Output: John
  }
}
```

## Flutter Example

Here’s a simple Flutter app that demonstrates `json_repair_flutter` in action. You can find the full example in the `example/lib/main.dart` file.

```dart
import 'package:flutter/material.dart';
import 'package:json_repair_flutter/json_repair_flutter.dart';

void main() => runApp(const JsonRepairDemoApp());

class JsonRepairDemoApp extends StatefulWidget {
  const JsonRepairDemoApp({super.key});

  @override
  State<JsonRepairDemoApp> createState() => _JsonRepairDemoAppState();
}

class _JsonRepairDemoAppState extends State<JsonRepairDemoApp> {
  final _controller = TextEditingController(text: "{name: 'Alice', age: 27,}");
  String? _repairedJson;
  String? _error;

  void _processJson() {
    setState(() {
      try {
        _repairedJson = repairJson(_controller.text);
        _error = null;
      } catch (e) {
        _repairedJson = null;
        _error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('JSON Repair Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Enter Malformed JSON',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _processJson,
                child: const Text('Repair JSON'),
              ),
              const SizedBox(height: 16),
              if (_repairedJson != null)
                SelectableText(
                  'Repaired JSON:\n$_repairedJson',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              if (_error != null)
                Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Supported Repairs

The library can handle a variety of common JSON errors. Here are a few examples:

| Malformed Input | Repaired Output | Description |
| :--- | :--- | :--- |
| `{name: "John"}` | `{"name": "John"}` | Adds quotes to unquoted keys. |
| `{'name': 'John'}` | `{"name": "John"}` | Converts single quotes to double quotes. |
| `[1, 2, 3,]` | `[1, 2, 3]` | Removes trailing commas. |
| `{"note": "hello //comment"}` | `{"note": "hello "}` | Strips single-line comments. |
| `{"user": /*comment*/ "Jane"}` | `{"user": "Jane"}` | Removes block comments. |
| `{"message": 'Hello\nWorld'}` | `{"message": "Hello World"}` | Handles and escapes multiline strings. |
| `{"a": "b"` | `{"a": "b"}` | Adds a missing closing brace. |

## API Reference

### Convenience Functions

For most use cases, these top-level functions are all you need:

- `String repairJson(String malformedJson)`: Takes a malformed JSON string and returns the repaired version.
- `dynamic repairJsonAndDecode(String malformedJson)`: Repairs the JSON string and then decodes it into a Dart `Map` or `List`.
- `dynamic repairJsonAndDecodeOrNull(String malformedJson)`: A safer alternative that returns `null` if the JSON cannot be repaired, instead of throwing an exception.

### Advanced: Custom Strategies

For more complex scenarios, you can create a `JsonRepairer` instance with a custom set of repair strategies:

```dart
import 'package:json_repair_flutter/json_repair_flutter.dart';

// Create a repairer with only specific fixes
final customRepairer = JsonRepairer.withStrategies([
  FixUnquotedKeysStrategy(),
  RemoveTrailingCommasStrategy(),
  // You can also add your own custom strategies here
]);

final partiallyFixedJson = customRepairer.repair(someMalformedJson);
```

## Troubleshooting

- **Repair Failure**: If the repair process fails, the input JSON may be too corrupted for the default strategies to handle. For more graceful error handling, use `repairJsonAndDecodeOrNull`.
- **Performance**: For very large JSON strings, the repair process may take time. Consider if preprocessing or batching is possible for your use case.
- **Complex Edge Cases**: If you encounter a specific type of malformed JSON that isn't handled, the API is designed to be extensible. You can implement your own `RepairStrategy` to address it.

## Contributing

Contributions are welcome! If you'd like to improve `json_repair_flutter`:

1.  **Fork** the repository.
2.  Create a new branch for your feature or bug fix.
3.  Submit a **pull request** with a clear description of your changes.

Feel free to open an issue to report bugs or suggest enhancements. Please adhere to the standard Dart/Flutter coding style.

## Changelog

For a detailed history of changes, please see the [`CHANGELOG.md`](CHANGELOG.md) file.

## License

This package is released under the **MIT License**.

Copyright (c) 2025 ONE CREST IT PRIVATE LIMITED

See the [LICENSE](LICENSE) file for the full license text.

---

**Built to bring reliability and robustness to your Flutter & Dart projects.**