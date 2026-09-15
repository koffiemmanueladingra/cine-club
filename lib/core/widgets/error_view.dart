import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../error/failures.dart';
import '../l10n/failure_l10n.dart';

/// État d'erreur plein écran, avec action de reprise.
///
/// Le message affiché vient de `failure.localizedMessage(l10n)` et non de
/// `failure.message` : l'échec porte un code, la traduction est choisie ici.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône purement décorative : le texte juste en dessous porte
            // déjà l'information, l'annoncer deux fois nuit à la lecture.
            ExcludeSemantics(
              child: Icon(_icon, size: 48, color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                failure.localizedMessage(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (failure) {
        NetworkFailure() => Icons.wifi_off_outlined,
        EmptyCacheFailure() => Icons.inbox_outlined,
        AuthFailure() => Icons.lock_outline,
        _ => Icons.error_outline,
      };
}
