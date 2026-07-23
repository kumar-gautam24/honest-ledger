import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/auth_session.dart';
import '../application/auth_state.dart';
import 'sync_overlay.dart';

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
        const SnackBar(content: Text('You’re in. Your data is backed up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final auth = ref.watch(authSessionProvider);

    // The syncing moment covers whatever is underneath (the account view, since
    // the email is set the instant credentials are accepted).
    if (auth.phase == AuthPhase.syncing) {
      return const SyncOverlay();
    }

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
          const SizedBox(height: AppSpacing.lg),
          const Center(child: AnimatedBrandMark(size: 88)),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              AppConstants.motto,
              style: context.text.titleMedium?.copyWith(color: c.textHi),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
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

class _SignedIn extends ConsumerWidget {
  const _SignedIn({required this.email, required this.onSignOut});

  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final busy = ref.watch(authSessionProvider).isBusy;
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
            onPressed: busy ? null : onSignOut,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Deleting your account permanently removes it and all its data from '
            'the cloud, and clears it from this device. This can’t be undone.',
            style: context.text.bodySmall?.copyWith(color: c.textMid),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: busy ? null : () => _confirmDelete(context, ref),
              style: TextButton.styleFrom(foregroundColor: c.cost),
              child: busy
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.cost,
                      ),
                    )
                  : const Text('Delete account'),
            ),
          ),
        ],
      ),
    );
  }

  /// Two-step, destructive confirmation before calling the delete endpoint, so a
  /// stray tap can't wipe an account. On success the session flips to signed-out
  /// and this screen rebuilds into the sign-in form.
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final c = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account and all your data from the '
          'cloud and removes it from this device. This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: c.cost),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(authSessionProvider.notifier).deleteAccount();
    if (!context.mounted) return;
    final message = ok
        ? 'Your account and data were deleted.'
        : (ref.read(authSessionProvider).error ??
            'Could not delete your account. Please try again.');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
