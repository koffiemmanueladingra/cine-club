import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();
    final auth = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: AsyncView<UserProfile>(
        state: controller.state,
        onRetry: controller.load,
        builder: (context, profile) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
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
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Nom affiché'),
              subtitle: Text(profile.displayName),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editName(context, profile.displayName),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Adresse e-mail'),
              subtitle: Text(auth.user?.email ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Identifiant'),
              subtitle: Text(profile.id),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: auth.isSubmitting ? null : auth.logout,
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, String current) async {
    final controller = context.read<ProfileController>();
    final textController = TextEditingController(text: current);
    final messenger = ScaffoldMessenger.of(context);

    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nom affiché'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(textController.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    textController.dispose();
    if (value == null || value.isEmpty || value == current) return;

    final ok = await controller.updateDisplayName(value);
    final failure = controller.actionFailure;
    if (!ok && failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}
