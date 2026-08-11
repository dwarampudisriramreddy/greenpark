import 'dart:io';

/// Central application configuration.
///
/// Supabase credentials are injected at build time via `--dart-define` so no
/// secret is hard-coded in source. The anon key below is the *public* client
/// key; it is safe to ship because all data access is guarded by Row Level
/// Security policies on the backend.
class AppConfig {
  AppConfig._();

  /// The Supabase project URL, overridable via `--dart-define=SUPABASE_URL=...`.
  static String get supabaseUrl => _resolve(
        const String.fromEnvironment('SUPABASE_URL'),
        'https://tygwlqvtxhepngwnnpqu.supabase.co',
      );

  /// Public anon key, overridable via `--dart-define=SUPABASE_ANON_KEY=...`.
  static String get supabaseAnonKey => _resolve(
        const String.fromEnvironment('SUPABASE_ANON_KEY'),
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Z3dscXZ0eGhlcG5nd25ucHF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY0MjA5OTMsImV4cCI6MjEwMTk5Njk5M30.sftEAz85bTr_-4jQOeTEYLKrK3YN7p0yettf29zGxtI',
      );

  static String _resolve(String envValue, String fallback) =>
      envValue.isEmpty ? fallback : envValue;

  /// Storage bucket names.
  static const String bucketMenuImages = 'menu-images';
  static const String bucketOfferBanners = 'offer-banners';
  static const String bucketPostImages = 'post-images';
  static const String bucketGalleryImages = 'gallery-images';
  static const String bucketRestaurantImages = 'restaurant-images';

  /// Fallback contact details (used only when backend data is missing).
  static const String fallbackPhone = '+91 85208 10444';
  static const String fallbackWhatsapp = '918520810444';
  static const String fallbackMapsUrl = 'https://maps.app.goo.gl/iXCVjkHzeiyT25ta7';

  /// Shared app platform targets.
  static bool get isAndroid => Platform.isAndroid;
}
