import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/failure_l10n.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.loginSubtitle, textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        // `labelText` est déjà exposé aux lecteurs d'écran par
                        // Flutter : pas besoin d'un `Semantics` supplémentaire,
                        // qui produirait une double annonce.
                        labelText: l10n.emailLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => _validateEmail(value, l10n),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip:
                              _obscure ? l10n.showPassword : l10n.hidePassword,
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            semanticLabel: _obscure
                                ? l10n.showPassword
                                : l10n.hidePassword,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? l10n.passwordRequired
                          : null,
                    ),
                    if (auth.failure != null) ...[
                      const SizedBox(height: 16),
                      _Message(
                        text: auth.failure!.localizedMessage(l10n),
                        color: theme.colorScheme.errorContainer,
                      ),
                    ],
                    if (auth.notice != null) ...[
                      const SizedBox(height: 16),
                      _Message(
                        text: _noticeText(auth.notice!, l10n),
                        color: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: auth.isSubmitting ? null : _submit,
                      child: auth.isSubmitting
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: l10n.loading,
                              ),
                            )
                          : Text(l10n.signIn),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: auth.isSubmitting ? null : _openRegister,
                      child: Text(l10n.createAccountLink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openRegister() {
    context.read<AuthController>().clearMessages();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthController>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  static String? _validateEmail(String? value, AppLocalizations l10n) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.emailRequired;
    if (!text.contains('@') || !text.contains('.')) return l10n.emailInvalid;
    return null;
  }
}

String _noticeText(AuthNotice notice, AppLocalizations l10n) =>
    switch (notice) {
      AuthNotice.confirmEmail => l10n.registerConfirmEmail,
      AuthNotice.sessionExpired => l10n.sessionExpired,
    };

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text),
        ),
      );
}
