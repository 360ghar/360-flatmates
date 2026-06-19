import 'safe_json_list.dart';

/// Parses the standard `{ items, next_cursor, has_more, limit }` envelope that
/// the backend uses for all paginated list endpoints.
///
/// Returns the parsed items plus the cursor metadata needed to request the
/// next page. When [envelope] is missing (or null), returns an empty list with
/// `hasMore=false` so callers can treat both empty inputs and missing keys
/// identically.
({List<T> items, String? nextCursor, bool hasMore}) parsePagedEnvelope<T>(
  Map<String, dynamic>? envelope,
  T Function(Map<String, dynamic> json) fromJson, {
  required String label,
}) {
  final data = envelope ?? const <String, dynamic>{};
  final items = safeJsonList(data['items'] as List?, fromJson, label: label);
  final rawNext = data['next_cursor'];
  final nextCursor = rawNext?.toString();
  final hasMore = data['has_more'] as bool? ?? nextCursor != null;
  return (items: items, nextCursor: nextCursor, hasMore: hasMore);
}
