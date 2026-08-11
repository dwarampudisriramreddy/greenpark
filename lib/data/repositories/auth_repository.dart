import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/restaurant_info.dart';
import '../supabase_client.dart';

/// Authentication + admin authorization for the CMS side of the app.
class AuthRepository {
  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get authState => supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => supabase.auth.signOut();

  Future<void> updatePassword(String newPassword) {
    return supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Whether the signed-in user is a registered restaurant admin.
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    final rows = await supabase
        .from('admins')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    return rows != null;
  }

  Future<String?> adminName() async {
    final user = currentUser;
    if (user == null) return null;
    return user.userMetadata?['full_name'] as String? ?? user.email;
  }
}

/// Content shared between admin screens.
class AdminStats {
  final int menuItems;
  final int activeOffers;
  final int publishedPosts;
  final int galleryImages;

  const AdminStats({
    required this.menuItems,
    required this.activeOffers,
    required this.publishedPosts,
    required this.galleryImages,
  });
}

/// Aggregate read for the admin dashboard.
Future<AdminStats> fetchAdminStats() async {
  final items = await supabase.from('menu_items').select('id').count();
  final offers = await supabase.from('offers').select('id').count();
  final posts = await supabase.from('posts').select('id').count();
  final gallery = await supabase.from('gallery_images').select('id').count();
  return AdminStats(
    menuItems: items.count,
    activeOffers: offers.count,
    publishedPosts: posts.count,
    galleryImages: gallery.count,
  );
}

/// Latest restaurant profile (for admin dashboard).
Future<RestaurantInfo> fetchRestaurantInfo() async {
  final rows = await supabase.from('restaurant_info').select().limit(1);
  if (rows.isEmpty) return const RestaurantInfo();
  return RestaurantInfo.fromMap(rows.first);
}
