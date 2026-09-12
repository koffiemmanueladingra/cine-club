class Cached<T> {
  const Cached(
    this.data, {
    this.fromCache = false,
    this.syncedAt,
  });

  final T data;

  final bool fromCache;

  final DateTime? syncedAt;

  Cached<T> copyWith({T? data, bool? fromCache, DateTime? syncedAt}) => Cached(
        data ?? this.data,
        fromCache: fromCache ?? this.fromCache,
        syncedAt: syncedAt ?? this.syncedAt,
      );
}
