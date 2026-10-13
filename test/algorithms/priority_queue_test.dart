import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:algorithmic_dungeon/algorithms/priority_queue.dart';

void main() {
  group('MinHeap Priority Queue', () {
    test('empty heap behavior', () {
      final heap = MinHeap<int>();
      expect(heap.isEmpty, isTrue);
      expect(heap.isNotEmpty, isFalse);
      expect(heap.length, equals(0));
      expect(heap.peek(), isNull);
      expect(() => heap.pop(), throwsStateError);
    });

    test('push and pop maintain min-heap order', () {
      final heap = MinHeap<int>();
      final values = [15, 3, 9, 1, 20, 8, 2];

      for (final v in values) {
        heap.push(v);
      }

      expect(heap.length, equals(7));
      expect(heap.peek(), equals(1));

      final extracted = <int>[];
      while (heap.isNotEmpty) {
        extracted.add(heap.pop());
      }

      expect(extracted, equals([1, 2, 3, 8, 9, 15, 20]));
      expect(heap.isEmpty, isTrue);
    });

    test('handles reverse-sorted insertions', () {
      final heap = MinHeap<int>();
      for (int i = 10; i >= 1; i--) {
        heap.push(i);
      }

      for (int expected = 1; expected <= 10; expected++) {
        expect(heap.pop(), equals(expected));
      }
    });

    test('handles duplicate priorities correctly', () {
      final heap = MinHeap<int>();
      heap.push(5);
      heap.push(2);
      heap.push(5);
      heap.push(2);
      heap.push(1);
      heap.push(5);

      expect(heap.pop(), equals(1));
      expect(heap.pop(), equals(2));
      expect(heap.pop(), equals(2));
      expect(heap.pop(), equals(5));
      expect(heap.pop(), equals(5));
      expect(heap.pop(), equals(5));
    });

    test('custom comparator works with custom objects', () {
      final heap = MinHeap<({String id, int cost})>(
        (a, b) => a.cost.compareTo(b.cost),
      );

      heap.push((id: 'c', cost: 30));
      heap.push((id: 'a', cost: 10));
      heap.push((id: 'b', cost: 20));

      expect(heap.pop().id, equals('a'));
      expect(heap.pop().id, equals('b'));
      expect(heap.pop().id, equals('c'));
    });

    test('large randomized sequence verifies heap invariant', () {
      final heap = MinHeap<int>();
      final random = Random(42);
      final rawList = List.generate(500, (_) => random.nextInt(10000));

      for (final num in rawList) {
        heap.push(num);
      }

      final sortedExpected = List<int>.from(rawList)..sort();
      final extracted = <int>[];

      while (heap.isNotEmpty) {
        extracted.add(heap.pop());
      }

      expect(extracted, equals(sortedExpected));
    });

    test('clear resets the heap', () {
      final heap = MinHeap<int>();
      heap.push(10);
      heap.push(20);
      heap.clear();

      expect(heap.isEmpty, isTrue);
      expect(heap.length, equals(0));
      expect(heap.peek(), isNull);
    });
  });
}
