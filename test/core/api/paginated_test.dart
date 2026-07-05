import 'package:flutter_test/flutter_test.dart';
import 'package:recurring/core/api/paginated.dart';

void main() {
  test('drains every page until has_more is false', () async {
    final pages = <int, Map<String, dynamic>>{
      0: {
        'items': [
          {'id': 'a'},
          {'id': 'b'}
        ],
        'next_cursor': 2,
        'has_more': true,
      },
      2: {
        'items': [
          {'id': 'c'}
        ],
        'next_cursor': 5,
        'has_more': false,
      },
    };
    final seen = <int>[];

    final result = await fetchAllPages<String>(
      (cursor) async {
        seen.add(cursor);
        return pages[cursor]!;
      },
      (m) => m['id'] as String,
    );

    expect(result, ['a', 'b', 'c']);
    expect(seen, [0, 2]); // followed the cursor
  });

  test('a single page returns without asking for more', () async {
    var calls = 0;
    final result = await fetchAllPages<String>(
      (_) async {
        calls++;
        return {
          'items': [
            {'id': 'x'}
          ],
          'next_cursor': 0,
          'has_more': false,
        };
      },
      (m) => m['id'] as String,
    );

    expect(result, ['x']);
    expect(calls, 1);
  });

  test('stops instead of looping forever if the cursor stalls', () async {
    var calls = 0;
    final result = await fetchAllPages<String>(
      (_) async {
        calls++;
        return {
          'items': [
            {'id': 'x'}
          ],
          'next_cursor': 0, // never advances past the starting cursor
          'has_more': true,
        };
      },
      (m) => m['id'] as String,
    );

    expect(calls, 1);
    expect(result, ['x']);
  });
}
