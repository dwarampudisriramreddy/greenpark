import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_logo.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final current = _current.text;
    final next = _newPassword.text;
    if (current.isEmpty) {
      setState(() => _message = 'Enter your current password.');
      return;
    }
    if (next.length < 8) {
      setState(() => _message = 'New password must be at least 8 characters.');
      return;
    }
    if (next != _confirm.text) {
      setState(() => _message = 'Passwords do not match.');
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) return;
      final email = user.email;
      if (email == null) return;
      await ref.read(authRepositoryProvider).signInWithEmail(email, current);
      await ref.read(authRepositoryProvider).updatePassword(next);
      _current.clear();
      _newPassword.clear();
      _confirm.clear();
      setState(() => _message = 'Password updated successfully.');
    } catch (_) {
      setState(() => _message = 'Could not update password. Check your current password.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authRepositoryProvider);
    final email = auth.currentUser?.email ?? '';
    final name = auth.currentUser?.userMetadata?['full_name'] as String?;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              AppLogo(size: 84),
              const SizedBox(height: 14),
              Text(name ?? 'Restaurant Admin', style: AppText.headline.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(email, style: AppText.subtitleFor(context)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Change password', style: AppText.headline),
        const SizedBox(height: 14),
        TextField(
          controller: _current,
          obscureText: _obscure,
          decoration: const InputDecoration(labelText: 'Current password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _newPassword,
          obscureText: _obscure,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirm,
          obscureText: _obscure,
          onSubmitted: (_) => _changePassword(),
          decoration: InputDecoration(
            labelText: 'Confirm new password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.inkSoft,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 14),
          Text(
            _message!,
            style: AppText.body.copyWith(
              color: _message!.contains('updated') ? AppColors.vegGreen : AppColors.accentRed,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _saving ? null : _changePassword,
          icon: const Icon(Icons.lock_reset_rounded),
          label: const Text('Update password'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brandGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            await ref.read(authRepositoryProvider).signOut();
            refreshAllContent(ref);
            if (context.mounted) {
              Navigator.of(context).popUntil((r) => r.isFirst);
            }
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
          label: const Text('Sign out of admin', style: TextStyle(color: AppColors.accentRed)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accentRed),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ],
    );
  }
}
