/// A promotional offer shown to customers.
class Offer {
  final String id;
  final String title;
  final String? description;
  final String? bannerUrl;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final String? terms;
  final bool isFeatured;
  final bool isActive;
  final DateTime createdAt;

  Offer({
    required this.id,
    required this.title,
    this.description,
    this.bannerUrl,
    this.validFrom,
    this.validUntil,
    this.terms,
    this.isFeatured = false,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  bool get isValid =>
      isActive &&
      (validFrom == null || !validFrom!.isAfter(DateTime.now())) &&
      (validUntil == null || !validUntil!.isBefore(DateTime.now()));

  factory Offer.fromMap(Map<String, dynamic> map) => Offer(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        bannerUrl: map['banner_url'] as String?,
        validFrom: map['valid_from'] == null ? null : DateTime.tryParse(map['valid_from'] as String),
        validUntil: map['valid_until'] == null ? null : DateTime.tryParse(map['valid_until'] as String),
        terms: map['terms'] as String?,
        isFeatured: map['is_featured'] as bool? ?? false,
        isActive: map['is_active'] as bool? ?? true,
        createdAt:
            DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'banner_url': bannerUrl,
        'valid_from': validFrom?.toIso8601String().split('T').first,
        'valid_until': validUntil?.toIso8601String().split('T').first,
        'terms': terms,
        'is_featured': isFeatured,
        'is_active': isActive,
      };

  Offer copyWith({
    String? title,
    String? description,
    String? bannerUrl,
    DateTime? validFrom,
    DateTime? validUntil,
    String? terms,
    bool? isFeatured,
    bool? isActive,
  }) =>
      Offer(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        bannerUrl: bannerUrl ?? this.bannerUrl,
        validFrom: validFrom ?? this.validFrom,
        validUntil: validUntil ?? this.validUntil,
        terms: terms ?? this.terms,
        isFeatured: isFeatured ?? this.isFeatured,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );
}
