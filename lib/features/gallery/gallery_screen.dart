import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/gallery_image.dart';
import '../../providers/providers.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/error_view.dart';
import '../../widgets/skeleton.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  String? _category;

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.line.withValues(alpha: 0.4)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshAllContent(ref),
        child: gallery.when(
          loading: () => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: 8,
            itemBuilder: (_, _) => const SkeletonBox(),
          ),
          error: (e, _) => ErrorView(
            message: 'Could not load the gallery.',
            onRetry: () async => refreshAllContent(ref),
          ),
          data: (list) {
            final categories = list.map((g) => g.category).whereType<String>().toSet().toList();
            var filtered = list;
            if (_category != null) {
              filtered = list.where((g) => g.category == _category).toList();
            }
            if (filtered.isEmpty) {
              return ListView(
                children: [
                  _categoryChips(categories),
                  const SizedBox(height: 120),
                  const Center(child: Text('No photos in this collection yet')),
                ],
              );
            }
            final left = <GalleryImage>[];
            final right = <GalleryImage>[];
            for (var i = 0; i < filtered.length; i++) {
              (i.isEven ? left : right).add(filtered[i]);
            }
            return ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 24),
              children: [
                _categoryChips(categories),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _masonryColumn(left, textDirection: TextDirection.ltr),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _masonryColumn(right, textDirection: TextDirection.rtl),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _categoryChips(List<String> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();
    final chips = <String?>[null, ...categories];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = chips[i];
          final selected = c == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.brandGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? AppColors.brandGreen : AppColors.line),
              ),
              child: Center(
                child: Text(
                  c ?? 'All',
                  style: AppText.title.copyWith(
                    fontSize: 12.5,
                    color: selected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _masonryColumn(List<GalleryImage> images, {required TextDirection textDirection}) {
    // Alternate image heights for a masonry feel.
    final heights = [170.0, 230.0, 190.0, 250.0, 180.0];
    return Directionality(
      textDirection: textDirection,
      child: Column(
        children: [
          for (var i = 0; i < images.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () => _openViewer(images, i),
                  child: AppNetworkImage(
                    url: images[i].imageUrl,
                    height: heights[i % heights.length],
                    width: double.infinity,
                    borderRadius: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openViewer(List<GalleryImage> images, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GalleryViewer(images: images, initialIndex: index),
      ),
    );
  }
}

class _GalleryViewer extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;
  const _GalleryViewer({required this.images, required this.initialIndex});

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.images[_index].category ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.images.length,
            itemBuilder: (_, i) {
              final g = widget.images[i];
              return Center(
                child: AppNetworkImage(
                  url: g.imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_index + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
