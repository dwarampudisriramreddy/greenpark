import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/feedback_review.dart';
import '../../providers/providers.dart';
import '../../widgets/app_button.dart';

/// Customers can share a review, complaint or suggestion.
class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  FeedbackKind _kind = FeedbackKind.review;
  int _rating = 5;
  bool _submitting = false;
  bool _done = false;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(feedbackRepositoryProvider).submit(FeedbackReview(
            id: '',
            customerName: _nameController.text.trim(),
            kind: _kind,
            rating: _rating,
            message: _messageController.text.trim(),
            contact: _contactController.text.trim().isEmpty
                ? null
                : _contactController.text.trim(),
            createdAt: DateTime.now(),
          ));
      setState(() => _done = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send your feedback. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Feedback'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: _done ? _SuccessView(onDone: () => Navigator.of(context).pop()) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.brandGreen, AppColors.brandGreenDark],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.forum_rounded, color: Colors.white, size: 28),
              const SizedBox(height: 10),
              Text('We value your feedback', style: AppText.headline.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'Your words help us serve you better.',
                style: AppText.bodySmallFor(context).copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('What would you like to share?', style: AppText.title),
        const SizedBox(height: 10),
        _kindSelector(),
        const SizedBox(height: 20),
        if (_kind == FeedbackKind.review) ...[
          Row(
            children: [
              Text('Your rating', style: AppText.title),
              const Spacer(),
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i <= _rating ? AppColors.accentGold : AppColors.inkSoft,
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  hintText: 'Optional',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: _kind == FeedbackKind.review
                      ? 'Share your experience'
                      : _kind == FeedbackKind.complaint
                          ? 'Tell us what went wrong'
                          : 'Share your idea',
                  hintText: 'Write a few words...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.edit_rounded),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please write something' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Contact (phone / email)',
                  hintText: 'Optional, so we can reach you',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: _submitting ? 'Sending...' : 'Send Feedback',
          icon: Icons.send_rounded,
          expanded: true,
          onPressed: _submitting ? null : _submit,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Your feedback goes directly to the restaurant team.',
            style: AppText.bodySmallFor(context),
          ),
        ),
      ],
    );
  }

  Widget _kindSelector() {
    return Row(
      children: [
        for (final kind in FeedbackKind.values) ...[
          if (kind != FeedbackKind.values.first) const SizedBox(width: 8),
          Expanded(
            child: _KindPill(
              kind: kind,
              selected: _kind == kind,
              onTap: () => setState(() => _kind = kind),
            ),
          ),
        ],
      ],
    );
  }
}

class _KindPill extends StatelessWidget {
  final FeedbackKind kind;
  final bool selected;
  final VoidCallback onTap;

  const _KindPill({required this.kind, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (kind) {
      FeedbackKind.review => (Icons.thumb_up_alt_rounded, AppColors.brandGreen),
      FeedbackKind.complaint => (Icons.report_problem_rounded, AppColors.accentRed),
      FeedbackKind.suggestion => (Icons.lightbulb_rounded, AppColors.accentGold),
    };
    return Material(
      color: selected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? color : AppColors.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                kind.label,
                style: AppText.bodySmallFor(context).copyWith(
                  color: selected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.brandMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.brandGreen, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Thank you!', style: AppText.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Your feedback has been sent to the Green Park team. We appreciate your time.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: onDone,
            ),
          ],
        ),
      ),
    );
  }
}
