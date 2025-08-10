---

# Changelog

All notable changes to the `json_repair_flutter` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2025-08-10

### Changed

-   **BREAKING: Complete Architectural Rewrite**. The entire library has been rebuilt from the ground up. The previous regular-expression-based engine has been replaced with a **robust, stateful parser**, ported from the popular Python `json-repair` library. This new approach is significantly more reliable and capable of handling complex and deeply nested JSON errors.
-   **BREAKING: Simplified Core API**. The API has been streamlined into a single, powerful function: `repairJson`. This function now directly parses the string into a Dart object (`dynamic`), making it more efficient by avoiding the creation of an intermediate repaired string.
-   The Flutter example app has been completely overhauled to demonstrate the new API and showcase the diagnostic logging feature.

### Added

-   **Diagnostic Logging**: Introduced an optional `logging` parameter to the `repairJson` function. When enabled, it returns a detailed log of all repair actions taken by the parser, which is invaluable for debugging the source of malformed JSON.
-   **Enhanced Repair Capabilities**: The new parser can handle more complex errors that were not possible with the regex approach, such as:
    -   Extracting JSON from surrounding text (e.g., LLM responses like `"Here is your data: {...}"`).
    -   Correctly parsing multiple, concatenated JSON objects (e.g., `{"a":1}{"b":2}`).
-   **Pure Dart Example**: Added a new command-line example (`example/bin/pure_dart_example.dart`) to demonstrate usage in non-Flutter environments.

### Removed

-   **BREAKING: Removed `JsonRepairer` and `RepairStrategy` System**. The extensible strategy pattern has been removed in favor of the more reliable and integrated parser. The new engine handles all previous repair cases and more, out of the box.
-   **BREAKING: Removed `repairJsonAndDecode` and `repairJsonAndDecodeOrNull`**. This functionality is now consolidated within the main `repairJson` function, which is now the single entry point for repairing and decoding.

### Fixed

-   Fixed numerous edge cases where the previous regex-based approach would fail or produce incorrect results, particularly with nested structures, escaped quotes, and complex string values.
-   Improved handling of multiline strings and comments, which are now managed correctly by the parser's state machine rather than by pattern matching.

---

## [1.0.0] - 2025-08-08

### Initial Release

-   **Core JSON Repair Engine**: First stable release of the `JsonRepairer`, providing a foundation for fixing malformed JSON using a strategy-based, regular expression engine.
-   **Comprehensive Repair Strategies**: Shipped with a set of default strategies to handle common JSON errors.
-   **Convenience Functions**: Added top-level `repairJson` (string-to-string) and `repairJsonAndDecode` functions.
-   **Extensible API**: Included `JsonRepairer.withStrategies` for custom repair pipelines.
-   **Flutter Example App**: Provided a sample Flutter application.
-   **Documentation**: Created initial documentation for the regex-based approach.