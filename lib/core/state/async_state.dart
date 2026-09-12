import '../error/failures.dart';

enum LoadStatus { idle, loading, ready, error }

class AsyncState<T> {
  const AsyncState({
    this.status = LoadStatus.idle,
    this.data,
    this.failure,
    this.fromCache = false,
    this.syncedAt,
  });

  final LoadStatus status;
  final T? data;
  final Failure? failure;

  final bool fromCache;

  final DateTime? syncedAt;

  bool get isLoading => status == LoadStatus.loading;
  bool get hasData => data != null;

  const AsyncState.loading()
      : status = LoadStatus.loading,
        data = null,
        failure = null,
        fromCache = false,
        syncedAt = null;

  AsyncState<T> toLoading() => AsyncState<T>(
        status: LoadStatus.loading,
        data: data,
        fromCache: fromCache,
        syncedAt: syncedAt,
      );

  AsyncState<T> toReady(T value, {bool fromCache = false, DateTime? syncedAt}) =>
      AsyncState<T>(
        status: LoadStatus.ready,
        data: value,
        fromCache: fromCache,
        syncedAt: syncedAt,
      );

  AsyncState<T> toError(Failure failure) => AsyncState<T>(
        status: LoadStatus.error,
        data: data,
        failure: failure,
        fromCache: fromCache,
        syncedAt: syncedAt,
      );
}
