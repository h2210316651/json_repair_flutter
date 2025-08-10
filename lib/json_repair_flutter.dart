import 'dart:convert';
import 'src/constants.dart';
import 'src/internal_parser.dart';

export 'src/constants.dart' show JSONReturnType;

/// Repairs a malformed JSON string.
///
/// Takes a potentially broken JSON string and returns a parsed Dart object (`Map`, `List`,
/// or primitive type). It first attempts to parse the string with the standard `jsonDecode`.
/// If that fails, it uses a forgiving parser that attempts to correct common errors.
///
/// - [jsonStr]: The JSON string to repair.
/// - [skipDecodeAttempt]: If true, the function will not try to use `jsonDecode` first
///   and will go straight to the repair process. Defaults to false.
/// - [logging]: If true, the function returns a `Map<String, dynamic>` containing the
///   repaired data under the 'data' key and a repair log under the 'log' key.
/// - [streamStable]: Aims to produce more stable results for JSON received from a stream,
///   preventing premature string termination.
///
/// Returns a `JSONReturnType` (dynamic). If `logging` is true, it returns a
/// `Map<String, dynamic>`.
JSONReturnType repairJson(
  String jsonStr, {
  bool skipDecodeAttempt = false,
  bool logging = false,
  bool streamStable = false,
}) {
  // The internal function that performs the repair.
  JSONReturnType doRepair() {
    final parser = InternalParser(
      jsonStr,
      logging: logging,
      streamStable: streamStable,
    );
    final result = parser.parse();
    if (logging) {
      return {'data': result, 'log': parser.logger};
    }
    return result;
  }

  if (skipDecodeAttempt) {
    return doRepair();
  }

  try {
    // Try the standard, strict parser first.
    final decoded = jsonDecode(jsonStr);
    if (logging) {
      // If logging is enabled but no repairs were needed, return an empty log.
      return {'data': decoded, 'log': []};
    }
    return decoded;
  } catch (e) {
    // If the standard parser fails, use our forgiving parser.
    return doRepair();
  }
}
