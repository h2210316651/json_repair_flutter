import 'package:collection/collection.dart';

/// A utility class for comparing objects.
class ObjectComparer {
  /// Recursively compares two objects to check if they have the same structure, type, and values.
  static bool isSameObject(dynamic obj1, dynamic obj2) {
    if (obj1.runtimeType != obj2.runtimeType) {
      return false;
    }

    if (obj1 is Map) {
      if (obj2 is! Map) return false;
      // Use deep equality from the collection package
      return const MapEquality().equals(obj1, obj2);
    }

    if (obj1 is List) {
      if (obj2 is! List) return false;
      // Use deep equality from the collection package
      return const ListEquality().equals(obj1, obj2);
    }

    // For primitives, the direct equality check is sufficient.
    return obj1 == obj2;
  }

  /// Returns true if the value is an empty container (String, List, Map, Set).
  /// Returns false for non-containers like null, 0, false, etc.
  static bool isStrictlyEmpty(dynamic value) {
    if (value is String || value is List || value is Map || value is Set) {
      return (value as dynamic).isEmpty;
    }
    return false;
  }
}
