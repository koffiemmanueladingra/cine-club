import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../l10n/app_localizations.dart';

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
