import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_picker_util.dart';
import '../../../data/models/post.dart';
import '../../../providers/providers.dart';
import '../../../widgets/app_network_image.dart';
import '../../../widgets/picked_image_preview.dart';

class PostEditScreen extends ConsumerStatefulWidget {
  final Post? post;
  const PostEditScreen({super.key, this.post});

  @override
  ConsumerState<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends ConsumerState<PostEditScreen> {
  static const _categories = [
    'New Dishes', 'Festival Specials', 'Events', 'Customer Celebrations',
    'Food Photography', 'Announcements',
  ];

  late final _title = TextEditingController(text: widget.post?.title ?? '');
  late final _description = TextEditingController(text: widget.post?.description ?? '');
  late String? _category = widget.post?.category ?? _categories.first;
  late bool _isPublished = widget.post?.isPublished ?? true;
  late bool _isFeatured = widget.post?.isFeatured ?? false;
  DateTime? _publishedAt;

  late final List<String> _existingImages = List.of(widget.post?.imageUrls ?? []);
  final List<PickedImage> _pickedImages = [];
  bool _saving = false;
  bool _uploading = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await pickMultipleImages();
    if (picked.isEmpty) return;
    setState(() => _pickedImages.addAll(picked));
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      _snack('Post title is required');
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(postRepositoryProvider);
      final storage = ref.read(storageRepositoryProvider);

      final existingId = widget.post?.id;
      setState(() => _uploading = true);

      final post = await repo.upsert(Post(
            id: existingId ?? '',
            title: title,
            description: _description.text.trim().isEmpty ? null : _description.text.trim(),
            category: _category,
            isPublished: _isPublished,
            isFeatured: _isFeatured,
            publishedAt:
                _isPublished ? (_publishedAt ?? widget.post?.publishedAt ?? DateTime.now()) : null,
            createdAt: widget.post?.createdAt ?? DateTime.now(),
          ));

      final urls = <String>[..._existingImages];
      for (final file in _pickedImages) {
        final url = await storage.uploadImage(
          bucket: AppConfig.bucketPostImages,
          bytes: file.bytes,
          extension: file.extension,
          prefix: 'posts',
        );
        urls.add(url);
      }
      await repo.setImages(post.id, urls);

      refreshAllContent(ref);
      if (mounted) {
        _snack(widget.post == null ? 'Post published' : 'Post updated');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) _snack('Could not save the post');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Post title'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in _categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _description,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Text('Images', style: AppText.headline.copyWith(fontSize: 15)),
              const Spacer(),
              TextButton.icon(
                onPressed: _uploading ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_existingImages.isNotEmpty || _pickedImages.isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _existingImages.length + _pickedImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final isNew = i >= _existingImages.length;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PickedImagePreview(
                        bytes: isNew
                            ? _pickedImages[i - _existingImages.length].bytes
                            : null,
                        width: 110,
                        height: 110,
                        borderRadius: 12,
                        fallback: isNew
                            ? null
                            : AppNetworkImage(
                                url: _existingImages[i],
                                width: 110,
                                height: 110,
                                borderRadius: 12,
                              ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            if (isNew) {
                              _pickedImages.removeAt(i - _existingImages.length);
                            } else {
                              _existingImages.removeAt(i);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ] else
            Center(
              child: GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.brandMint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brandGreen.withValues(alpha: 0.5),
                      width: 1.4,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: AppColors.brandGreen, size: 30),
                      SizedBox(height: 6),
                      Text(
                        'Add photos to your post',
                        style: TextStyle(color: AppColors.brandGreen, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 22),

          SwitchListTile(
            value: _isPublished,
            onChanged: (v) => setState(() => _isPublished = v),
            title: const Text('Published'),
            subtitle: const Text('Customers can see this post'),
            activeThumbColor: AppColors.brandGreen,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _isFeatured,
            onChanged: (v) => setState(() => _isFeatured = v),
            title: const Text('Featured'),
            subtitle: const Text('Highlighted across the app'),
            activeThumbColor: AppColors.accentGold,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save post'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
