/// Menu category, e.g. Starters, Biryanis, Desserts.
class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        icon: map['icon'] as String?,
        imageUrl: map['image_url'] as String?,
        sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
        isActive: map['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'icon': icon,
        'image_url': imageUrl,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

  Category copyWith({String? name, String? description, String? icon, String? imageUrl, int? sortOrder, bool? isActive}) =>
      Category(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        imageUrl: imageUrl ?? this.imageUrl,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
      );
}
