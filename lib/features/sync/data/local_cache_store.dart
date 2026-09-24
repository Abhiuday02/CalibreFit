/// In-memory and structured collection-based local cache store.
/// Provides atomic operations for offline-first persistence across all features.
class LocalCacheStore {
  LocalCacheStore();

  final Map<String, Map<String, Map<String, dynamic>>> _store = {};

  /// Writes or overwrites a record [data] identified by [id] under [collection].
  Future<void> put(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final col = _store.putIfAbsent(collection, () => {});
    col[id] = Map<String, dynamic>.from(data);
  }

  /// Retrieves a cached record by [id] within [collection].
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final col = _store[collection];
    if (col == null || !col.containsKey(id)) return null;
    return Map<String, dynamic>.from(col[id]!);
  }

  /// Retrieves all records in [collection].
  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    final col = _store[collection];
    if (col == null) return [];
    return col.values.map((v) => Map<String, dynamic>.from(v)).toList();
  }

  /// Deletes a record by [id] from [collection].
  Future<void> delete(String collection, String id) async {
    _store[collection]?.remove(id);
  }

  /// Clears an entire [collection].
  Future<void> clearCollection(String collection) async {
    _store[collection]?.clear();
  }

  /// Clears all collections in the cache store.
  Future<void> clearAll() async {
    _store.clear();
  }

  /// Counts the total records in [collection].
  int count(String collection) => _store[collection]?.length ?? 0;

  /// Total count across all collections.
  int get totalRecordsCount =>
      _store.values.fold(0, (sum, col) => sum + col.length);
}
