import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_picker_util.dart';
import '../../../data/models/gallery_image.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/skeleton.dart';

class GalleryAdminScreen extends ConsumerWidget {
  const GalleryAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(galleryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _uploadImages(context, ref),
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Upload photos'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: gallery.when(
          loading: () => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: 6,
            itemBuilder: (_, _) => const SkeletonBox(),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load the gallery.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 140),
                  const Center(child: Text('No photos yet. Tap + to upload.')),
                ],
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => _GalleryTile(
                image: list[i],
                onTogglePublish: () => _togglePublish(context, ref, list[i]),
                onDelete: () => _confirmDelete(context, ref, list[i]),
                onEdit: () => _editMeta(context, ref, list[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _uploadImages(BuildContext context, WidgetRef ref) async {
    final picked = await pickMultipleImages();
    if (picked.isEmpty || !context.mounted) return;
    final storage = ref.read(storageRepositoryProvider);
    final repo = ref.read(galleryRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    final nextOrder =
        ref.read(galleryProvider).maybeWhen(
              data: (l) => l.length,
              orElse: () => 0,
            ) +
        1;

    messenger.showSnackBar(
      const SnackBar(content: Text('Uploading photos…')),
    );
    for (final f in picked) {
      final url = await storage.uploadImage(
        bucket: AppConfig.bucketGalleryImages,
        bytes: f.bytes,
        extension: f.extension,
        prefix: 'gallery',
      );
      await repo.upsert(GalleryImage(
        id: '',
        imageUrl: url,
        isPublished: true,
        sortOrder: nextOrder,
      ));
    }
    refreshAllContent(ref);
    messenger.showSnackBar(
      SnackBar(content: Text('${picked.length} photo(s) uploaded')),
    );
  }

  Future<void> _togglePublish(BuildContext context, WidgetRef ref, GalleryImage image) async {
    await ref.read(galleryRepositoryProvider).togglePublished(image);
    refreshAllContent(ref);
  }

  Future<void> _editMeta(BuildContext context, WidgetRef ref, GalleryImage image) async {
    final title = TextEditingController(text: image.title ?? '');
    final category = TextEditingController(text: image.category ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;
    await ref.read(galleryRepositoryProvider).upsert(GalleryImage(
          id: image.id,
          title: title.text.trim().isEmpty ? null : title.text.trim(),
          category: category.text.trim().isEmpty ? null : category.text.trim(),
          imageUrl: image.imageUrl,
          isPublished: image.isPublished,
          sortOrder: image.sortOrder,
        ));
    refreshAllContent(ref);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, GalleryImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete photo?'),
        content: const Text('This photo will be removed from the gallery.'),
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
    await ref.read(galleryRepositoryProvider).delete(image.id);
    refreshAllContent(ref);
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryImage image;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _GalleryTile({
    required this.image,
    required this.onTogglePublish,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AppNetworkImage(url: image.imageUrl),
        ),
        if (!image.isPublished)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text(
              'HIDDEN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
        Positioned(
          top: 6,
          left: 6,
          child: GestureDetector(
            onTap: onTogglePublish,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                image.isPublished ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 6,
          left: 6,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, size: 15, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 6,
          right: 6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, size: 15, color: Colors.white),
            ),
          ),
        ),
        if (image.title != null && image.title!.isNotEmpty)
          Positioned(
            bottom: 8,
            left: 44,
            right: 44,
            child: Text(
              image.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),
      ],
    );
  }
}
