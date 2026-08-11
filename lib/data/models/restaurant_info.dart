/// Restaurant profile loaded from the CMS.
class RestaurantInfo {
  final String name;
  final String? tagline;
  final String? about;
  final String? address;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final Map<String, Map<String, String>> openingHours;
  final String? mapsUrl;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? logoUrl;
  final String? heroImageUrl;

  const RestaurantInfo({
    this.name = 'Green Park Family Restaurant',
    this.tagline,
    this.about,
    this.address,
    this.phone,
    this.whatsapp,
    this.email,
    this.openingHours = const {},
    this.mapsUrl,
    this.instagramUrl,
    this.facebookUrl,
    this.logoUrl,
    this.heroImageUrl,
  });

  factory RestaurantInfo.fromMap(Map<String, dynamic> map) {
    final hoursRaw = map['opening_hours'];
    Map<String, Map<String, String>> hours = {};
    if (hoursRaw is Map) {
      hoursRaw.forEach((key, value) {
        if (value is Map) {
          hours[key.toString()] = {
            for (final e in value.entries) e.key.toString(): e.value.toString(),
          };
        }
      });
    }
    return RestaurantInfo(
      name: map['name'] as String? ?? 'Green Park Family Restaurant',
      tagline: map['tagline'] as String?,
      about: map['about'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      whatsapp: map['whatsapp'] as String?,
      email: map['email'] as String?,
      openingHours: hours,
      mapsUrl: map['maps_url'] as String?,
      instagramUrl: map['instagram_url'] as String?,
      facebookUrl: map['facebook_url'] as String?,
      logoUrl: map['logo_url'] as String?,
      heroImageUrl: map['hero_image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'tagline': tagline,
        'about': about,
        'address': address,
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'opening_hours': openingHours,
        'maps_url': mapsUrl,
        'instagram_url': instagramUrl,
        'facebook_url': facebookUrl,
        'logo_url': logoUrl,
        'hero_image_url': heroImageUrl,
      };
}
