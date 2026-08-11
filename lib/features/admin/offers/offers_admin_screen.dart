import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/offer.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/skeleton.dart';
import 'offer_edit_screen.dart';

class OffersAdminScreen extends ConsumerWidget {
  const OffersAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(allOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OfferEditScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New offer'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: offers.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: 3,
            itemBuilder: (_, _) => const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: SkeletonBox(height: 200),
            ),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load offers.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (list) {
            final sorted = [...list]..sort((a, b) {
                final aActive = a.isActive ? 1 : 0;
                final bActive = b.isActive ? 1 : 0;
                if (aActive != bActive) return bActive - aActive;
                return b.createdAt.compareTo(a.createdAt);
              });
            if (sorted.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  const Center(child: Text('No offers yet. Tap + to create one.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OfferRow(
                offer: sorted[i],
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => OfferEditScreen(offer: sorted[i])),
                ),
                onDelete: () => _confirmDelete(context, ref, sorted[i]),
                onToggleActive: () => _toggleActive(context, ref, sorted[i]),
                onToggleFeatured: () => _toggleFeatured(context, ref, sorted[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, WidgetRef ref, Offer offer) async {
    await ref.read(offerRepositoryProvider).toggleActive(offer);
    refreshAllContent(ref);
  }

  Future<void> _toggleFeatured(BuildContext context, WidgetRef ref, Offer offer) async {
    await ref.read(offerRepositoryProvider).toggleFeatured(offer);
    refreshAllContent(ref);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete offer?'),
        content: Text('"${offer.title}" will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(offerRepositoryProvider).delete(offer.id);
      refreshAllContent(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete the offer')),
        );
      }
    }
  }
}

class _OfferRow extends StatelessWidget {
  final Offer offer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleFeatured;

  const _OfferRow({
    required this.offer,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    final expired = offer.validUntil != null && offer.validUntil!.isBefore(DateTime.now());
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1B231E)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AppNetworkImage(url: offer.bannerUrl, width: 84, height: 64),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(offer.title, style: AppText.title.copyWith(fontSize: 14.5)),
                            const SizedBox(height: 4),
                            Text(
                              _metaText(offer),
                              style: AppText.bodySmallFor(context).copyWith(fontSize: 11.5),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (!offer.isActive)
                                  _statusPill('Inactive', AppColors.inkSoft, AppColors.line)
                                else if (expired)
                                  _statusPill('Expired', AppColors.accentRed, AppColors.accentRedLight)
                                else
                                  _statusPill('Active', AppColors.vegGreen, AppColors.brandMint),
                                if (offer.isFeatured) _statusPill('Featured', const Color(0xFF7A5D10), AppColors.accentGoldLight),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.published_with_changes_rounded, size: 18),
                  tooltip: offer.isActive ? 'Deactivate' : 'Activate',
                  onPressed: onToggleActive,
                  color: AppColors.brandGreen,
                ),
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  tooltip: offer.isFeatured ? 'Unfeature' : 'Feature',
                  onPressed: onToggleFeatured,
                  color: offer.isFeatured ? AppColors.accentGold : AppColors.inkSoft,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  color: AppColors.brandGreen,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  onPressed: onDelete,
                  color: AppColors.accentRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _metaText(Offer offer) {
    if (offer.validFrom == null && offer.validUntil == null) return 'Ongoing offer';
    if (offer.validUntil == null) return 'From ${formatDate(offer.validFrom!)}';
    if (offer.validFrom == null) return 'Till ${formatDate(offer.validUntil!)}';
    return '${formatDate(offer.validFrom!)} - ${formatDate(offer.validUntil!)}';
  }

  Widget _statusPill(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
