/// A single dish on the digital menu.
class MenuItem {
  final String id;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isVeg;
  final bool isSpicy;
  final bool isBestseller;
  final bool isAvailable;
  final bool isActive;
  final int sortOrder;

  const MenuItem({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isVeg = true,
    this.isSpicy = false,
    this.isBestseller = false,
    this.isAvailable = true,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) => MenuItem(
        id: map['id'] as String,
        categoryId: map['category_id'] as String?,
        name: map['name'] as String,
        description: map['description'] as String?,
        price: (map['price'] as num).toDouble(),
        imageUrl: map['image_url'] as String?,
        isVeg: map['is_veg'] as bool? ?? true,
        isSpicy: map['is_spicy'] as bool? ?? false,
        isBestseller: map['is_bestseller'] as bool? ?? false,
        isAvailable: map['is_available'] as bool? ?? true,
        isActive: map['is_active'] as bool? ?? true,
        sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'is_veg': isVeg,
        'is_spicy': isSpicy,
        'is_bestseller': isBestseller,
        'is_available': isAvailable,
        'is_active': isActive,
        'sort_order': sortOrder,
      };

  MenuItem copyWith({
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isVeg,
    bool? isSpicy,
    bool? isBestseller,
    bool? isAvailable,
    bool? isActive,
    int? sortOrder,
  }) =>
      MenuItem(
        id: id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        isVeg: isVeg ?? this.isVeg,
        isSpicy: isSpicy ?? this.isSpicy,
        isBestseller: isBestseller ?? this.isBestseller,
        isAvailable: isAvailable ?? this.isAvailable,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
      );
}
