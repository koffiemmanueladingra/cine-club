import 'package:flutter/material.dart';

import '../state/async_state.dart';
import 'error_view.dart';
import 'offline_banner.dart';

class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.state,
    required this.builder,
    this.onRetry,
  });

  final AsyncState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.status == LoadStatus.error && !state.hasData) {
      return ErrorView(
        failure: state.failure!,
        onRetry: onRetry == null ? null : () => onRetry!(),
      );
    }

    if (!state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = builder(context, state.data as T);

    return Column(
      children: [
        if (state.fromCache) OfflineBanner(syncedAt: state.syncedAt),
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: onRetry == null
              ? content
              : RefreshIndicator(onRefresh: onRetry!, child: content),
        ),
      ],
    );
  }
}
