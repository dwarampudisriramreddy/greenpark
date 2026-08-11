/// An Instagram-style restaurant update.
class Post {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final bool isFeatured;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final List<String> imageUrls;

  const Post({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.isFeatured = false,
    this.isPublished = true,
    this.publishedAt,
    required this.createdAt,
    this.imageUrls = const [],
  });

  factory Post.fromMap(Map<String, dynamic> map) => Post(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        category: map['category'] as String?,
        isFeatured: map['is_featured'] as bool? ?? false,
        isPublished: map['is_published'] as bool? ?? true,
        publishedAt: map['published_at'] == null
            ? null
            : DateTime.tryParse(map['published_at'] as String),
        createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'is_featured': isFeatured,
        'is_published': isPublished,
        'published_at': publishedAt?.toUtc().toIso8601String(),
      };

  Post copyWith({
    String? title,
    String? description,
    String? category,
    bool? isFeatured,
    bool? isPublished,
    DateTime? publishedAt,
  }) =>
      Post(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        isFeatured: isFeatured ?? this.isFeatured,
        isPublished: isPublished ?? this.isPublished,
        publishedAt: publishedAt ?? this.publishedAt,
        createdAt: createdAt,
        imageUrls: imageUrls,
      );
}
