# Changelog

All notable changes to the `json_repair_flutter` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2025-08-08

### Initial Release

-   **Core JSON Repair Engine**: First stable release of the `JsonRepairer`, providing a robust foundation for fixing malformed JSON.
-   **Comprehensive Repair Strategies**: Shipped with a complete set of default strategies to handle the most common JSON errors:
    -   `FixUnquotedKeysStrategy`
    -   `FixSingleQuotesStrategy`
    -   `RemoveTrailingCommasStrategy`
    -   `AddMissingValueQuotesStrategy`
    -   `FixUnclosedStructuresStrategy`
    -   `RemoveCommentsStrategy` (for both line and block comments)
    -   `FixEscapedQuotesStrategy`
    -   `FixMultilineStringsStrategy`
-   **Convenience Functions**: Added top-level `repairJson` and `repairJsonAndDecode` functions for easy, one-line usage in any Dart or Flutter project.
-   **Extensible API**: Included `JsonRepairer.withStrategies` to allow developers to create custom repair pipelines or add new strategies for handling unique edge cases.
-   **Flutter Example App**: Provided a sample Flutter application in the `example` directory to demonstrate real-world usage and integration.
-   **Documentation**: Created comprehensive documentation, including a detailed README, API reference, and inline code comments to guide developers.