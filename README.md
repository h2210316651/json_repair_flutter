# `json_repair` for Dart & Flutter: Effortlessly Fix Broken JSON

[![pub package](https://img.shields.io/pub/v/json_repair_flutter.svg)](https://pub.dev/packages/json_repair_flutter)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)

A robust Dart and Flutter package to repair malformed JSON, ported from the popular Python [`json-repair`](https://github.com/mvelazc0/json-repair) library.

Instead of relying on fragile regular expressions, this library implements a **forgiving parser** that intelligently understands the structure of your JSON and fixes it. It's designed to handle the messy, incomplete, or slightly invalid JSON often returned by LLMs, APIs, or user input, making your applications exceptionally resilient to data format errors.

## Why a Parser-Based Approach?

The previous regex-based version faced limitations and could fail on complex edge cases. This new version is a complete rewrite, using a stateful parser that walks through the string character by character. This allows it to:

- Reliably fix structural issues (missing braces, commas, quotes).
- Correctly handle nested and complex data.
- Avoid the "brittle" nature of regex, ensuring more predictable and accurate repairs.
- Provide detailed logging of the repairs it performs.

## Key Features

- **Handles All Common JSON Errors**:
    - **Trailing Commas**: Removes invalid trailing commas from objects and arrays.
    - **Resolves Unquoted Keys & Strings**: Adds missing quotes around keys and values (e.g., `{key: value}` → `{"key": "value"}`).
    - **Corrects Quote Types**: Converts single quotes to the required double quotes.
    - **Closes Unfinished Structures**: Safely adds missing closing braces `}` and brackets `]`.
    - **Strips Comments**: Removes JavaScript-style line (`//`) and block (`/* ... */`) comments.
    - **Normalizes Escaped Characters**: Fixes improperly escaped quotes and control characters.
    - **Handles Extraneous Text**: Can extract a valid JSON object from a string containing leading or trailing text (e.g., from an LLM response).

- **Diagnostic Logging**: Get a step-by-step log of every fix the parser applies, making debugging a breeze.
- **Simple, Powerful API**: A single function to handle all your JSON repair needs.
- **Cross-Platform**: Works seamlessly in Flutter, pure Dart (CLI, server-side), and on the web.

## Quick Start

### 1. Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  json_repair_flutter: ^2.0.0 # Use the latest version
```

Then, run `flutter pub get` or `dart pub get`.

### 2. Basic Usage

Repairing and decoding JSON is now handled by a single, powerful function: `repairJson`.

```dart
import 'package:json_repair_flutter/json_repair_flutter.dart';
import 'dart:convert';

void main() {
  // A string with multiple errors: unquoted keys, single quotes, trailing comma
  const malformedJson = "{name: 'John Doe', age: 30, cities: ['New York', 'London',],}";

  // Repair the JSON and get a Dart object
  final decodedData = repairJson(malformedJson);

  // Pretty-print the result
  const encoder = JsonEncoder.withIndent('  ');
  print(encoder.convert(decodedData));
  /*
    Output:
    {
      "name": "John Doe",
      "age": 30,
      "cities": [
        "New York",
        "London"
      ]
    }
  */

  if (decodedData is Map<String, dynamic>) {
    print(decodedData['name']); // Output: John Doe
  }
}
```

## API Reference

### `repairJson(String jsonStr, {bool logging = false, ...})`

This is the primary function of the library.

- **Parameters**:
    - `jsonStr`: The malformed JSON string you want to fix.
    - `logging` (optional, `false`): If set to `true`, the function returns a `Map<String, dynamic>` containing the repaired `'data'` and a `'log'` of all repair actions.
    - `skipDecodeAttempt` (optional, `false`): By default, the library first tries the standard `jsonDecode`. If this is `true`, it skips that check and goes directly to the repair parser.
    - `streamStable` (optional, `false`): Improves behavior for incomplete JSON from streams, preventing premature trimming of characters.

- **Returns**:
    - By default (`logging: false`), it returns the repaired `JSONReturnType` (`dynamic`), which will be a `Map`, `List`, or primitive.
    - With `logging: true`, it returns a `Map<String, dynamic>` like this:
      ```json
      {
        "data": { "repaired": "json_object" },
        "log": [
          { "text": "While parsing an object we missed a : after a key", "context": "..." },
          { "text": "While parsing a string, we missed the closing quote, ignoring", "context": "..." }
        ]
      }
      ```

## Supported Repairs

The parser can handle a wide variety of malformations.

| Malformed Input | Repaired Output (as Dart object) |
| :--- | :--- |
| `{key: "value"}` | `{"key": "value"}` |
| `{'key': 'value',}` | `{"key": "value"}` |
| `["a", "b",]` | `["a", "b"]` |
| `// comment\n{"a": 1}` | `{"a": 1}` |
| `{"a": 1} /* block */` | `{"a": 1}` |
| `{"a": "b"` | `{"a": "b"}` |
| `{"a":1}{"b":2}` | `[{"a": 1}, {"b": 2}]` |
| `I think this is it: {"a":1}`| `{"a": 1}` |

## Contributing

Contributions are welcome! If you've found a bug or have a feature request:

1.  Please open an issue to discuss the change.
2.  **Fork** the repository and create a new branch.
3.  Submit a **pull request** with a clear description of your changes.

## License

This package is released under the **MIT License**. See the [LICENSE](LICENSE) file for details.