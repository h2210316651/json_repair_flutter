import 'dart:convert';
import 'package:json_repair_flutter/json_repair_flutter.dart';

// A map containing various examples of malformed JSON strings.
final Map<String, String> brokenJsonExamples = {
  'Missing Closing Brace': '{"key": "value", "anotherKey": "anotherValue"',
  'Trailing Comma in Object': '{"key": "value",}',
  'Unquoted Keys': '{key: "value", anotherKey: "anotherValue"}',
  'Single Quotes': "{'key': 'value'}",
  'Missing Value': '{"key": }',
  'Mixed Quotes & No Comma':
      '{\'key\': "value" "anotherKey": \'anotherValue\'}',
  'Line Comments (// and #)': '''
  {
    // This is a comment
    "key": "value",
    # Another comment style
    "anotherKey": "anotherValue"
  }
  ''',
  'Block Comments (/* ... */)': '''
  /* 
    This is a block comment
    explaining the object below.
  */
  { "id": 123 }
  ''',
  'Incomplete String Value': '{"key": "this string is not closed',
  'Array with Trailing Comma': '["a", "b",]',
  'Text before JSON':
      'Here is the JSON you requested: {"name": "John Doe", "items": ["item1", "item2", "item3"]}',
  'Unescaped Newlines': '''
  {
    "address": "123 Main St
    Anytown, USA"
  }
  ''',
  'Concatenated JSON Objects': '{"a":1}{"b":2}',
};

void main() {
  print('--- Running Pure Dart JSON Repair Examples ---');

  // Use an encoder for pretty-printing the JSON output
  const jsonEncoder = JsonEncoder.withIndent('  ');

  // Iterate over each test case
  for (final entry in brokenJsonExamples.entries) {
    final caseName = entry.key;
    final brokenJson = entry.value;

    print('\n=============================================');
    print('>>> Testing Case: $caseName');
    print('=============================================');

    print('\nOriginal (Malformed) JSON:');
    print('--------------------------');
    print(brokenJson);

    try {
      // Call the repairJson function with logging enabled.
      // The function returns a map with 'data' and 'log' keys.
      final result = repairJson(
        brokenJson,
        logging: true,
      ) as Map<String, dynamic>;

      final repairedData = result['data'];
      final repairLogs = result['log'] as List<dynamic>;

      // Pretty-print the repaired Dart object
      final formattedRepairedJson = jsonEncoder.convert(repairedData);

      print('\nRepaired JSON Output:');
      print('---------------------');
      print(formattedRepairedJson);

      // Display the repair logs if any actions were taken
      if (repairLogs.isNotEmpty) {
        print('\nRepair Actions Log:');
        print('-------------------');
        for (final logEntry in repairLogs) {
          final log = logEntry as Map<String, dynamic>;
          print(" - Action: ${log['text']}");
          print("   Context: ...${log['context']}...");
        }
      } else {
        print(
            '\n✅ No repair actions were needed (original JSON was likely valid or fixed without specific logging).');
      }
    } catch (e) {
      print('\n❌ An unexpected error occurred during repair:');
      print(e);
    }
  }

  print('\n--- All examples processed. ---\n');
}
