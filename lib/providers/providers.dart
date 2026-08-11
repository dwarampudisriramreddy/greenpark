import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/category.dart';
import '../data/models/feedback_review.dart';
import '../data/models/gallery_image.dart';
import '../data/models/menu_item.dart';
import '../data/models/offer.dart';
import '../data/models/post.dart';
import '../data/models/restaurant_info.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/feedback_repository.dart';
import '../data/repositories/gallery_repository.dart';
import '../data/repositories/menu_repository.dart';
import '../data/repositories/offer_repository.dart';
import '../data/repositories/post_repository.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/storage_repository.dart';

// --- App settings -----------------------------------------------------------

/// Persisted app theme mode (light / dark / follow system).
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == null) return;
    for (final mode in ThemeMode.values) {
      if (mode.name == saved) {
        state = mode;
        return;
      }
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

// --- Repositories -----------------------------------------------------------

final restaurantRepositoryProvider = Provider<RestaurantRepository>((_) => RestaurantRepository());
final menuRepositoryProvider = Provider<MenuRepository>((_) => MenuRepository());
final offerRepositoryProvider = Provider<OfferRepository>((_) => OfferRepository());
final postRepositoryProvider = Provider<PostRepository>((_) => PostRepository());
final galleryRepositoryProvider = Provider<GalleryRepository>((_) => GalleryRepository());
final feedbackRepositoryProvider = Provider<FeedbackRepository>((_) => FeedbackRepository());
final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());
final storageRepositoryProvider = Provider<StorageRepository>((_) => StorageRepository());

// --- Auth -------------------------------------------------------------------

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).authState;
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  if (repo.currentUser == null) return false;
  return repo.isAdmin();
});

// --- Content ----------------------------------------------------------------

final restaurantInfoProvider = FutureProvider<RestaurantInfo>((ref) {
  return ref.watch(restaurantRepositoryProvider).fetch();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(menuRepositoryProvider).fetchCategories();
});

final menuItemsProvider = FutureProvider<List<MenuItem>>((ref) {
  return ref.watch(menuRepositoryProvider).fetchMenuItems();
});

final offersProvider = FutureProvider<List<Offer>>((ref) {
  return ref.watch(offerRepositoryProvider).fetchActive();
});

final postsProvider = FutureProvider<List<Post>>((ref) {
  return ref.watch(postRepositoryProvider).fetch();
});

final galleryProvider = FutureProvider<List<GalleryImage>>((ref) {
  return ref.watch(galleryRepositoryProvider).fetch();
});

/// Published customer reviews shown on the home showcase.
final publishedReviewsProvider = FutureProvider<List<FeedbackReview>>((ref) {
  return ref.watch(feedbackRepositoryProvider).fetchPublished();
});

/// Every feedback row for the admin inbox.
final allFeedbackProvider = FutureProvider<List<FeedbackReview>>((ref) {
  return ref.watch(feedbackRepositoryProvider).fetchAll();
});

// --- Admin variants (RLS returns every row for admins) ----------------------

/// Every offer including expired/inactive ones (admin screens only).
final allOffersProvider = FutureProvider<List<Offer>>((ref) {
  return ref.watch(offerRepositoryProvider).fetch();
});

/// Every post including drafts (admin screens only).
final allPostsProvider = FutureProvider<List<Post>>((ref) {
  return ref.watch(postRepositoryProvider).fetchFlat();
});

// --- Admin ------------------------------------------------------------------

final adminStatsProvider = FutureProvider((ref) => fetchAdminStats());

/// Invalidates every cached content provider so screens reload fresh data.
/// Call after any admin edit (or pull-to-refresh).
void refreshAllContent(WidgetRef ref) {
  ref.invalidate(restaurantInfoProvider);
  ref.invalidate(categoriesProvider);
  ref.invalidate(menuItemsProvider);
  ref.invalidate(offersProvider);
  ref.invalidate(postsProvider);
  ref.invalidate(galleryProvider);
  ref.invalidate(allOffersProvider);
  ref.invalidate(allPostsProvider);
  ref.invalidate(publishedReviewsProvider);
  ref.invalidate(allFeedbackProvider);
  ref.invalidate(adminStatsProvider);
}
