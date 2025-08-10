/// Represents the current parsing context within the JSON structure.
enum ContextValues {
  objectKey,
  objectValue,
  array,
}

/// Manages the parsing context stack.
class JsonContext {
  final List<ContextValues> _context = [];
  ContextValues? _current;
  bool _empty = true;

  /// The current context value.
  ContextValues? get current => _current;

  /// Returns true if the context stack is empty.
  bool get isEmpty => _empty;

  /// Returns the full context stack.
  List<ContextValues> get context => _context;

  /// Pushes a new context value onto the stack.
  void set(ContextValues value) {
    _context.add(value);
    _current = value;
    _empty = false;
  }

  /// Pops the most recent context value from the stack.
  void reset() {
    if (_context.isNotEmpty) {
      _context.removeLast();
      if (_context.isNotEmpty) {
        _current = _context.last;
      } else {
        _current = null;
        _empty = true;
      }
    } else {
      _current = null;
      _empty = true;
    }
  }
}
