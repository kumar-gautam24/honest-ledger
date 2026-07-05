/// Drains a cursor-paginated list endpoint into a single list.
///
/// The backend paginates every list with keyset cursors on a monotonic
/// `server_seq`: each page is `{items, next_cursor, has_more}` and the next
/// request passes the previous `next_cursor`. [getPage] fetches one page for a
/// cursor (starting at 0); [map] converts each raw item. Stops when `has_more`
/// is false, or defensively if the cursor fails to advance.
Future<List<T>> fetchAllPages<T>(
  Future<Map<String, dynamic>> Function(int cursor) getPage,
  T Function(Map<String, dynamic>) map,
) async {
  final out = <T>[];
  var cursor = 0;
  while (true) {
    final data = await getPage(cursor);
    for (final item in data['items'] as List) {
      out.add(map(item as Map<String, dynamic>));
    }
    if (data['has_more'] != true) break;
    final next = data['next_cursor'] as int;
    if (next <= cursor) break; // defensive: the cursor must strictly advance
    cursor = next;
  }
  return out;
}
