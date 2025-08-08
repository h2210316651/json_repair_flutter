import 'package:flutter_test/flutter_test.dart';
import 'package:json_repair_flutter/json_repair_flutter.dart';

void main() {
  group('JsonRepairer Tests', () {
    late JsonRepairer repairer;

    setUp(() {
      repairer = JsonRepairer();
    });

    test('should repair unquoted keys', () {
      const malformed = '{name: "John", age: 30}';
      const expected = '{"name": "John", "age": 30}';

      final result = repairer.repair(malformed);
      expect(result, equals(expected));
    });

    test('should fix single quotes', () {
      const malformed = "{'name': 'John', 'age': 30}";
      const expected = '{"name": "John", "age": 30}';

      final result = repairer.repair(malformed);
      expect(result, equals(expected));
    });

    test('should remove trailing commas', () {
      const malformed = '{"name": "John", "age": 30,}';
      const expected = '{"name": "John", "age": 30}';

      final result = repairer.repair(malformed);
      expect(result, equals(expected));
    });

    test('should add missing closing braces', () {
      const malformed = '{"name": "John", "age": 30';
      const expected = '{"name": "John", "age": 30}';

      final result = repairer.repair(malformed);
      expect(result, equals(expected));
    });

    test('should repair and decode successfully', () {
      const malformed = '{name: "John", age: 30,}';

      final result = repairer.repairAndDecode(malformed);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], equals('John'));
      expect(result['age'], equals(30));
    });

    test('should return null for unrepairable JSON', () {
      const malformed = '{{{invalid json';

      final result = repairer.repairAndDecodeOrNull(malformed);
      expect(result, isNull);
    });

    test('should handle arrays with trailing commas', () {
      const malformed = '[1, 2, 3,]';
      const expected = '[1, 2, 3]';

      final result = repairer.repair(malformed);
      expect(result, equals(expected));
    });
  });

  group('Convenience Functions Tests', () {
    test('repairJson should work', () {
      const malformed = '{name: "John"}';
      const expected = '{"name": "John"}';

      final result = repairJson(malformed);
      expect(result, equals(expected));
    });

    test('repairJsonAndDecode should work', () {
      const malformed = '{name: "John"}';

      final result = repairJsonAndDecode(malformed);
      expect(result['name'], equals('John'));
    });
  });
}
