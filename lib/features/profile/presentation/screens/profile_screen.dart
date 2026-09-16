import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../core/settings/locale_controller.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final l10n = AppLocalizations.of(context);
    final email = context.select<AuthController, String?>((c) => c.user?.email);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: AsyncView<UserProfile>(
        state: controller.state,
        onRetry: controller.load,
        builder: (context, profile) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Semantics(
                label: l10n.avatarOf(profile.displayName),
                child: ExcludeSemantics(
                  child: CircleAvatar(
                    radius: 36,
                    child: Text(
                      profile.displayName.isEmpty
                          ? '?'
                          : profile.displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l10n.displayNameLabel),
              subtitle: Text(profile.displayName),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editName(context, profile.displayName),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text(l10n.emailLabel),
              subtitle: Text(email ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: Text(l10n.userIdLabel),
              subtitle: Text(profile.id),
            ),
            const Divider(height: 32),
            const _LanguageTile(),
            const SizedBox(height: 24),
            const _SignOutButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final controller = context.read<ProfileController>();
    final l10n = AppLocalizations.of(context);
    final textController = TextEditingController(text: current);
    final messenger = ScaffoldMessenger.of(context);

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editDisplayNameTitle),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.displayNameLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(textController.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    textController.dispose();
    if (value == null || value.isEmpty || value == current) return;

    final ok = await controller.updateDisplayName(value);
    if (ok) return;

    final failure = controller.actionFailure;
    if (failure == null) return;
    messenger.showSnackBar(
      SnackBar(content: Text(failure.localizedMessage(l10n))),
    );
  }
}

/// Sélecteur de langue.
///
/// `null` signifie « suivre le système » ; c'est aussi ce que `MaterialApp`
/// attend dans son paramètre `locale`.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = context.select<LocaleController, Locale?>(
      (c) => c.locale,
    );

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.languageLabel),
      trailing: DropdownButton<String>(
        value: selected?.languageCode ?? 'system',
        // Le libellé du menu est aussi le libellé lu : pas de `Semantics`
        // supplémentaire, `DropdownButton` expose déjà un nœud bouton.
        items: [
          DropdownMenuItem(value: 'system', child: Text(l10n.languageSystem)),
          DropdownMenuItem(value: 'fr', child: Text(l10n.languageFrench)),
          DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
        ],
        onChanged: (value) => context.read<LocaleController>().setLocale(
              value == null || value == 'system' ? null : Locale(value),
            ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSubmitting =
        context.select<AuthController, bool>((c) => c.isSubmitting);

    return FilledButton.tonalIcon(
      onPressed:
          isSubmitting ? null : () => context.read<AuthController>().logout(),
      icon: const Icon(Icons.logout),
      label: Text(l10n.signOut),
    );
  }
}
