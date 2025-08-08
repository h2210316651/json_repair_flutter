/// Abstract base class for JSON repair strategies
abstract class RepairStrategy {
  String apply(String json);
}

/// Removes leading and trailing commas
class RemoveLeadingTrailingCommasStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    // Remove leading commas
    json = json.replaceAll(RegExp(r'(?<=[\[\{,]\s*),'), '');
    // Remove trailing commas before closing brackets
    json = json.replaceAllMapped(
      RegExp(r',(\s*[\]\}])'),
      (match) => match.group(1)!,
    );
    return json;
  }
}

/// Fixes unquoted keys by adding double quotes
class FixUnquotedKeysStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    // Match unquoted keys (word characters followed by colon)
    return json.replaceAllMapped(
      RegExp(r'(?<=[{\[,]\s*)([a-zA-Z_$][a-zA-Z0-9_$]*)\s*:'),
      (match) => '"${match.group(1)}":',
    );
  }
}

/// Converts single quotes to double quotes
class FixSingleQuotesStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    final buffer = StringBuffer();
    bool inDoubleQuotes = false;
    bool inSingleQuotes = false;
    bool escaped = false;

    for (int i = 0; i < json.length; i++) {
      final char = json[i];

      if (escaped) {
        buffer.write(char);
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        buffer.write(char);
        continue;
      }

      if (char == '"' && !inSingleQuotes) {
        inDoubleQuotes = !inDoubleQuotes;
        buffer.write(char);
      } else if (char == "'" && !inDoubleQuotes) {
        if (!inSingleQuotes) {
          inSingleQuotes = true;
          buffer.write('"');
        } else {
          inSingleQuotes = false;
          buffer.write('"');
        }
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}

/// Removes trailing commas before closing brackets
class RemoveTrailingCommasStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    return json.replaceAllMapped(
      RegExp(r',\s*([}\]])'),
      (match) => match.group(1)!,
    );
  }
}

/// Adds quotes around unquoted string values
class FixMissingQuotesAroundValuesStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    // Fix unquoted values that are not numbers, booleans, or null
    return json.replaceAllMapped(
      RegExp(r':\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*(?=[,}\]])'),
      (match) {
        final value = match.group(1)!;
        if (value == 'true' || value == 'false' || value == 'null') {
          return match.group(0)!;
        }
        return ': "$value"';
      },
    );
  }
}

/// Adds missing closing braces and brackets
class AddMissingClosingBracesStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    final stack = <String>[];
    final result = StringBuffer();
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < json.length; i++) {
      final char = json[i];
      if (escaped) {
        result.write(char);
        escaped = false;
        continue;
      }
      if (char == '\\' && inString) {
        escaped = true;
        result.write(char);
        continue;
      }
      if (char == '"' && !escaped) {
        inString = !inString;
      }
      if (!inString) {
        if (char == '{') {
          stack.add('}');
        } else if (char == '[') {
          stack.add(']');
        } else if (char == '}' || char == ']') {
          if (stack.isNotEmpty && stack.last == char) {
            stack.removeLast();
          }
        }
      }
      result.write(char);
    }
    // Add missing closing brackets
    while (stack.isNotEmpty) {
      result.write(stack.removeLast());
    }
    return result.toString();
  }
}

/// Removes comments from JSON
class RemoveCommentStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    // Remove single-line comments
    json = json.replaceAll(RegExp(r'//.*$', multiLine: true), '');
    // Remove multi-line comments
    json = json.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    return json;
  }
}

/// Fixes escaped quotes issues
class FixEscapedQuotesStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    // Fix common escaped quote issues
    return json.replaceAll(RegExp(r'\\"'), '"');
  }
}

/// Handles multiline strings by converting them to single line
class FixMultilineStringStrategy implements RepairStrategy {
  @override
  String apply(String json) {
    return json.replaceAll(RegExp(r'\n\s*'), ' ');
  }
}
