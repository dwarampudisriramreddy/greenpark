/// A photo in the gallery.
class GalleryImage {
  final String id;
  final String? title;
  final String? category;
  final String imageUrl;
  final bool isPublished;
  final int sortOrder;

  const GalleryImage({
    required this.id,
    this.title,
    this.category,
    required this.imageUrl,
    this.isPublished = true,
    this.sortOrder = 0,
  });

  factory GalleryImage.fromMap(Map<String, dynamic> map) => GalleryImage(
        id: map['id'] as String,
        title: map['title'] as String?,
        category: map['category'] as String?,
        imageUrl: map['image_url'] as String,
        isPublished: map['is_published'] as bool? ?? true,
        sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'image_url': imageUrl,
        'is_published': isPublished,
        'sort_order': sortOrder,
      };
}
