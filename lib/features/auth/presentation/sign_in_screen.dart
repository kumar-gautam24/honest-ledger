import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/auth_session.dart';

/// Optional cloud sign-in. The app works fully without it; signing in pushes your
/// saves to the backend and pulls your data down on a new device. Toggles between
/// "log in" and "create account".
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final notifier = ref.read(authSessionProvider.notifier);
    final ok = _isRegister
        ? await notifier.register(email, password)
        : await notifier.signIn(email, password);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in — your data is syncing.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final auth = ref.watch(authSessionProvider);

    if (auth.isSignedIn) {
      return _SignedIn(email: auth.email!, onSignOut: () {
        ref.read(authSessionProvider.notifier).signOut();
      });
    }

    return AppScaffold(
      title: _isRegister ? 'Create account' : 'Sign in',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Text(
            'Sign in to back up your data and use it on any device. The app keeps '
            'working offline either way.',
            style: context.text.bodyMedium?.copyWith(color: c.textMid),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            hint: 'you@example.com',
            autofocus: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PasswordField(controller: _password, onSubmitted: (_) => _submit()),
          if (auth.error != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              auth.error!,
              style: context.text.bodySmall?.copyWith(color: c.cost),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _isRegister ? 'Create account' : 'Sign in',
            loading: auth.isBusy,
            onPressed: auth.isBusy ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: _isRegister
                ? 'I already have an account'
                : 'Create a new account',
            variant: AppButtonVariant.ghost,
            onPressed: auth.isBusy
                ? null
                : () => setState(() => _isRegister = !_isRegister),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Password',
      controller: controller,
      hint: 'At least 8 characters',
      textInputAction: TextInputAction.done,
      onSubmitted: onSubmitted,
    );
  }
}

class _SignedIn extends StatelessWidget {
  const _SignedIn({required this.email, required this.onSignOut});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      title: 'Account',
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          AppCard(
            child: Row(
              children: [
                Icon(Icons.cloud_done_outlined, color: c.accent),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Signed in', style: context.text.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(email, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.secondary,
            onPressed: onSignOut,
          ),
        ],
      ),
    );
  }
}
