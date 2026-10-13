/// A generic binary min-heap implementation for priority queue operations.
///
/// Ensures O(log V) insertion and extraction, maintaining the minimum element
/// at the root according to the provided [comparator].
class MinHeap<T> {
  final List<T> _elements = [];
  final int Function(T a, T b) _comparator;

  /// Creates a min-heap with a custom [comparator].
  ///
  /// If no comparator is supplied and [T] implements [Comparable], natural ordering
  /// is used where lower values have higher priority.
  MinHeap([int Function(T a, T b)? comparator])
    : _comparator = comparator ?? _defaultComparator<T>();

  static int Function(T a, T b) _defaultComparator<T>() {
    return (T a, T b) {
      if (a is Comparable) {
        return a.compareTo(b);
      }
      throw ArgumentError(
        'Type $T is not Comparable. A custom comparator must be provided.',
      );
    };
  }

  /// Number of elements currently in the heap.
  int get length => _elements.length;

  /// Returns true if the heap contains no elements.
  bool get isEmpty => _elements.isEmpty;

  /// Returns true if the heap contains one or more elements.
  bool get isNotEmpty => _elements.isNotEmpty;

  /// Returns the minimum element without removing it, or `null` if empty.
  T? peek() => _elements.isEmpty ? null : _elements[0];

  /// Inserts [item] into the min-heap and restores the heap invariant in O(log N).
  void push(T item) {
    _elements.add(item);
    _bubbleUp(_elements.length - 1);
  }

  /// Removes and returns the minimum element from the heap in O(log N).
  ///
  /// Throws a [StateError] if the heap is empty.
  T pop() {
    if (_elements.isEmpty) {
      throw StateError('Cannot pop from an empty MinHeap');
    }

    final min = _elements[0];
    final last = _elements.removeLast();

    if (_elements.isNotEmpty) {
      _elements[0] = last;
      _bubbleDown(0);
    }

    return min;
  }

  /// Empties all elements from the heap.
  void clear() {
    _elements.clear();
  }

  void _bubbleUp(int index) {
    var currentIndex = index;

    while (currentIndex > 0) {
      final parentIndex = (currentIndex - 1) >> 1;

      if (_comparator(_elements[currentIndex], _elements[parentIndex]) < 0) {
        final temp = _elements[currentIndex];
        _elements[currentIndex] = _elements[parentIndex];
        _elements[parentIndex] = temp;
        currentIndex = parentIndex;
      } else {
        break;
      }
    }
  }

  void _bubbleDown(int index) {
    var currentIndex = index;
    final length = _elements.length;

    while (true) {
      final leftIndex = (currentIndex << 1) + 1;
      final rightIndex = leftIndex + 1;
      var smallestIndex = currentIndex;

      if (leftIndex < length &&
          _comparator(_elements[leftIndex], _elements[smallestIndex]) < 0) {
        smallestIndex = leftIndex;
      }

      if (rightIndex < length &&
          _comparator(_elements[rightIndex], _elements[smallestIndex]) < 0) {
        smallestIndex = rightIndex;
      }

      if (smallestIndex != currentIndex) {
        final temp = _elements[currentIndex];
        _elements[currentIndex] = _elements[smallestIndex];
        _elements[smallestIndex] = temp;
        currentIndex = smallestIndex;
      } else {
        break;
      }
    }
  }
}
