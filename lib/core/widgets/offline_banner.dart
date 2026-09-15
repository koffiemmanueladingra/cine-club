import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../l10n/app_localizations.dart';

/// Bandeau signalant que les données affichées viennent du cache local.
///
/// La date est formatée par `intl.DateFormat` avec la locale active, et non
/// par un `padLeft` maison : `15/01/2026 10:30` en français devient
/// `1/15/2026 10:30 AM` en anglais américain.
///
/// `liveRegion: true` fait annoncer le bandeau par les lecteurs d'écran au
/// moment où il apparaît, sans que l'utilisateur ait à le chercher.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.syncedAt});

  final DateTime? syncedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    final date = syncedAt;
    final text = date == null
        ? l10n.offlineNoDate
        : l10n.offlineSince(
            intl.DateFormat.yMd(localeName).add_Hm().format(date.toLocal()),
          );

    return Semantics(
      liveRegion: true,
      child: Material(
        color: theme.colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const ExcludeSemantics(
                child: Icon(Icons.cloud_off_outlined, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
            ],
          ),
        ),
      ),
    );
  }
}
