import 'dart:math';
import 'package:collection/collection.dart';
import 'constants.dart';
import 'json_context.dart';
import 'object_comparer.dart';

/// An internal, stateful parser that repairs and decodes a JSON string.
/// This class is not intended for public use. Use the top-level `repairJson` function.
class InternalParser {
  String jsonStr;
  int index = 0;
  final JsonContext context = JsonContext();
  final bool logging;
  final List<Map<String, String>> logger = [];
  final bool streamStable;

  InternalParser(this.jsonStr,
      {this.logging = false, this.streamStable = false});

  void _log(String text) {
    if (!logging) return;
    int window = 10;
    int start = max(index - window, 0);
    int end = min(index + window, jsonStr.length);
    String contextStr = jsonStr.substring(start, end);
    logger.add({
      'text': text,
      'context': contextStr,
    });
  }

  /// Main entry point for parsing the JSON string.
  JSONReturnType parse() {
    JSONReturnType json = _parseJson();
    if (index < jsonStr.length) {
      _log("The parser returned early, checking if there's more json elements");
      List<JSONReturnType> resultList = [json];
      while (index < jsonStr.length) {
        JSONReturnType j = _parseJson();
        if (j != "") {
          if (resultList.isNotEmpty &&
              ObjectComparer.isSameObject(resultList.last, j)) {
            // Replace the last entry with the new one since it seems to be an update.
            resultList.removeLast();
          }
          resultList.add(j);
        } else {
          // Move the index to avoid infinite loops on invalid characters.
          index++;
        }
      }
      // If nothing extra was found, don't return an array
      if (resultList.length == 1) {
        _log(
            "There were no more elements, returning the element without the array");
        json = resultList[0];
      } else {
        json = resultList;
      }
    }
    return json;
  }

  /// Dispatches to the correct parsing function based on the current character.
  JSONReturnType _parseJson() {
    while (index < jsonStr.length) {
      String? char = _getCharAt();
      if (char == null) return "";

      switch (char) {
        case '{':
          index++;
          return _parseObject();
        case '[':
          index++;
          return _parseArray();
      }

      if (!context.isEmpty &&
          (stringDelimiters.contains(char) || _isAlpha(char))) {
        return _parseString();
      } else if (!context.isEmpty &&
          (_isDigit(char) || char == '-' || char == '.')) {
        return _parseNumber();
      } else if (char == '#' || char == '/') {
        return _parseComment();
      } else {
        // If everything else fails, ignore and move on.
        index++;
      }
    }
    return "";
  }

  /// Skips comments and returns an empty string or the next parsed JSON element.
  JSONReturnType _parseComment() {
    String? char = _getCharAt();
    if (char == null) return "";

    final terminationCharacters = ['\n', '\r'];
    if (context.context.contains(ContextValues.array))
      terminationCharacters.add(']');
    if (context.context.contains(ContextValues.objectValue))
      terminationCharacters.add('}');
    if (context.context.contains(ContextValues.objectKey))
      terminationCharacters.add(':');

    if (char == '#') {
      final commentStart = index;
      while (_getCharAt() != null &&
          !terminationCharacters.contains(_getCharAt())) {
        index++;
      }
      _log(
          "Found line comment: ${jsonStr.substring(commentStart, index)}, ignoring");
    } else if (char == '/') {
      String? nextChar = _getCharAt(1);
      if (nextChar == '/') {
        // Line comment
        final commentStart = index;
        index += 2;
        while (_getCharAt() != null &&
            !terminationCharacters.contains(_getCharAt())) {
          index++;
        }
        _log(
            "Found line comment: ${jsonStr.substring(commentStart, index)}, ignoring");
      } else if (nextChar == '*') {
        // Block comment
        final commentStart = index;
        index += 2;
        while (_getCharAt() != null) {
          if (_getCharAt(0) == '*' && _getCharAt(1) == '/') {
            index += 2;
            break;
          }
          index++;
        }
        _log(
            "Found block comment: ${jsonStr.substring(commentStart, index)}, ignoring");
      } else {
        index++; // Standalone '/'
      }
    }

    if (context.isEmpty) {
      return _parseJson();
    }
    return "";
  }

  List<JSONReturnType> _parseArray() {
    List<JSONReturnType> arr = [];
    context.set(ContextValues.array);
    String? char = _getCharAt();

    while (char != null && char != ']' && char != '}') {
      _skipWhitespaces();
      JSONReturnType value = _parseJson();

      if (ObjectComparer.isStrictlyEmpty(value)) {
        // Handle cases like `[,"a"]` or `[,"a",]`
        // Skip the comma if it's not followed by a value
        _skipWhitespaces();
        if (_getCharAt() == ',') {
          index++;
        }
      } else {
        arr.add(value);
      }

      // Skip over whitespace and comma after a value
      _skipWhitespaces();
      char = _getCharAt();
      if (char == ',') {
        index++;
        _skipWhitespaces();
        char = _getCharAt();
      }
    }

    if (char != ']') {
      _log("While parsing an array we missed the closing ], ignoring it");
    } else {
      index++;
    }

    context.reset();
    return arr;
  }

  Map<String, JSONReturnType> _parseObject() {
    Map<String, JSONReturnType> obj = {};

    while (_getCharAt() != null && _getCharAt() != '}') {
      _skipWhitespaces();

      if (_getCharAt() == ':') {
        _log("While parsing an object we found a : before a key, ignoring");
        index++;
        continue;
      }

      context.set(ContextValues.objectKey);
      String key = _parseString().toString();
      _skipWhitespaces();

      if (key.isEmpty && _getCharAt() == '}') break;

      if (_getCharAt() != ':') {
        _log("While parsing an object we missed a : after a key");
      } else {
        index++;
      }

      context.reset();
      context.set(ContextValues.objectValue);

      _skipWhitespaces();
      JSONReturnType value;
      if (['}', ','].contains(_getCharAt())) {
        value = ""; // Handle missing value
        _log(
            "While parsing an object value we found a stray , or } ignoring it");
      } else {
        value = _parseJson();
      }
      obj[key] = value;
      context.reset();

      _skipWhitespaces();
      if (_getCharAt() == ',') {
        index++;
      }
    }

    if (_getCharAt() == '}') {
      index++;
    }
    return obj;
  }

  /// Parses a string value, handling various forms of malformation.
  JSONReturnType _parseString() {
    bool missingQuotes = false;
    String lstringDelimiter = '"';
    String rstringDelimiter = '"';

    _skipWhitespaces();
    String? char = _getCharAt();
    if (char == null) return "";

    if (char == '#' || char == '/') return _parseComment();

    if (!stringDelimiters.contains(char)) {
      if (_isAlpha(char)) {
        if (['t', 'f', 'n'].contains(char.toLowerCase()) &&
            context.current != ContextValues.objectKey) {
          final boolOrNull = _parseBooleanOrNull();
          if (boolOrNull != "") return boolOrNull;
        }
        _log("While parsing a string, we found a literal instead of a quote");
        missingQuotes = true;
      } else {
        return ""; // Not a valid start for a string
      }
    } else {
      lstringDelimiter = char;
      rstringDelimiter = {'“': '”', '”': '“', "'": "'", '"': '"'}[char]!;
      index++;
    }

    String stringAcc = "";
    char = _getCharAt();

    while (char != null && char != rstringDelimiter) {
      // Handle unquoted strings in objects
      if (missingQuotes) {
        if (context.current == ContextValues.objectKey &&
            (char == ':' || char.trim().isEmpty)) break;
        if (context.current == ContextValues.objectValue &&
            [',', '}'].contains(char)) break;
      }

      // Handle escaped characters
      if (char == '\\') {
        stringAcc += char; // Add the backslash
        index++;
        char = _getCharAt();
        if (char != null) {
          stringAcc += char; // Add the character after backslash
          index++;
          char = _getCharAt();
        }
        continue;
      }

      stringAcc += char;
      index++;
      char = _getCharAt();
    }

    if (char == rstringDelimiter) {
      index++;
    } else if (!missingQuotes) {
      _log("While parsing a string, we missed the closing quote, ignoring");
    }

    if (missingQuotes || (stringAcc.isNotEmpty && stringAcc.endsWith('\n'))) {
      return stringAcc.trimRight();
    }

    return stringAcc;
  }

  /// Parses `true`, `false`, or `null`.
  JSONReturnType _parseBooleanOrNull() {
    final startingIndex = index;

    bool? tryParse(String keyword, bool? value) {
      if (jsonStr.length >= startingIndex + keyword.length &&
          jsonStr
                  .substring(startingIndex, startingIndex + keyword.length)
                  .toLowerCase() ==
              keyword) {
        index += keyword.length;
        return value;
      }
      return null;
    }

    String? char = _getCharAt()?.toLowerCase();
    if (char == 't') {
      if (tryParse('true', true) != null) return true;
    } else if (char == 'f') {
      if (tryParse('false', false) != null) return false;
    } else if (char == 'n') {
      if (tryParse('null', null) != null) return null;
    }

    index = startingIndex;
    return ""; // Return empty string to indicate parsing failure.
  }

  /// Parses a number (integer or double).
  JSONReturnType _parseNumber() {
    final start = index;
    String? char = _getCharAt();

    while (char != null && '0123456789-.eE'.contains(char)) {
      index++;
      char = _getCharAt();
    }

    String numberStr = jsonStr.substring(start, index);

    try {
      if (numberStr.contains('.') ||
          numberStr.contains('e') ||
          numberStr.contains('E')) {
        return double.parse(numberStr);
      } else {
        return int.parse(numberStr);
      }
    } catch (e) {
      // If parsing fails, return it as a string.
      return numberStr;
    }
  }

  // Helper functions
  String? _getCharAt([int count = 0]) {
    final pos = index + count;
    if (pos >= 0 && pos < jsonStr.length) {
      return jsonStr[pos];
    }
    return null;
  }

  void _skipWhitespaces() {
    while (index < jsonStr.length && jsonStr[index].trim().isEmpty) {
      index++;
    }
  }

  bool _isAlpha(String char) => char.toLowerCase() != char.toUpperCase();
  bool _isDigit(String char) => '0123456789'.contains(char);
}
