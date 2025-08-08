import 'dart:convert';
import 'repair_strategies.dart';

/// Main class for repairing malformed JSON strings
class JsonRepairer {
  final List<RepairStrategy> _strategies;

  /// Creates a JsonRepairer with default repair strategies
  JsonRepairer() : _strategies = _defaultStrategies();

  /// Creates a JsonRepairer with custom repair strategies
  JsonRepairer.withStrategies(this._strategies);

  /// Attempts to repair a malformed JSON string
  /// Returns the repaired JSON string
  String repair(String malformedJson) {
    String result = malformedJson.trim();

    for (final strategy in _strategies) {
      result = strategy.apply(result);
    }

    return result;
  }

  /// Attempts to repair and decode a malformed JSON string
  /// Returns the decoded object or throws FormatException if repair fails
  dynamic repairAndDecode(String malformedJson) {
    try {
      // First try to decode as-is
      return jsonDecode(malformedJson);
    } catch (e) {
      // If that fails, try to repair and decode
      final repairedJson = repair(malformedJson);
      return jsonDecode(repairedJson);
    }
  }

  /// Attempts to repair and decode with fallback
  /// Returns the decoded object or null if repair fails
  dynamic repairAndDecodeOrNull(String malformedJson) {
    try {
      return repairAndDecode(malformedJson);
    } catch (e) {
      return null;
    }
  }

  static List<RepairStrategy> _defaultStrategies() {
    return [
      RemoveLeadingTrailingCommasStrategy(),
      FixUnquotedKeysStrategy(),
      FixSingleQuotesStrategy(),
      RemoveTrailingCommasStrategy(),
      FixMissingQuotesAroundValuesStrategy(),
      AddMissingClosingBracesStrategy(),
      RemoveCommentStrategy(),
      FixEscapedQuotesStrategy(),
      FixMultilineStringStrategy(),
    ];
  }
}

/// Convenience function to repair JSON string
String repairJson(String malformedJson) {
  return JsonRepairer().repair(malformedJson);
}

/// Convenience function to repair and decode JSON string
dynamic repairJsonAndDecode(String malformedJson) {
  return JsonRepairer().repairAndDecode(malformedJson);
}
