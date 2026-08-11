import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category.dart';
import '../data/models/gallery_image.dart';
import '../data/models/menu_item.dart';
import '../data/models/offer.dart';
import '../data/models/post.dart';
import '../data/models/restaurant_info.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/gallery_repository.dart';
import '../data/repositories/menu_repository.dart';
import '../data/repositories/offer_repository.dart';
import '../data/repositories/post_repository.dart';
import '../data/repositories/restaurant_repository.dart';
import '../data/repositories/storage_repository.dart';

// --- Repositories -----------------------------------------------------------

final restaurantRepositoryProvider = Provider<RestaurantRepository>((_) => RestaurantRepository());
final menuRepositoryProvider = Provider<MenuRepository>((_) => MenuRepository());
final offerRepositoryProvider = Provider<OfferRepository>((_) => OfferRepository());
final postRepositoryProvider = Provider<PostRepository>((_) => PostRepository());
final galleryRepositoryProvider = Provider<GalleryRepository>((_) => GalleryRepository());
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
  ref.invalidate(adminStatsProvider);
}
