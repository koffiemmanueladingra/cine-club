import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.syncedAt});

  final DateTime? syncedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                syncedAt == null
                    ? 'Mode hors ligne — données enregistrées sur l\'appareil.'
                    : 'Mode hors ligne — données du ${_format(syncedAt!.toLocal())}.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _format(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)} à ${two(date.hour)}:${two(date.minute)}';
  }
}
