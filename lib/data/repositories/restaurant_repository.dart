import '../models/restaurant_info.dart';
import '../supabase_client.dart';

/// Reads and updates the single restaurant profile row.
class RestaurantRepository {
  Future<RestaurantInfo> fetch() async {
    final rows = await supabase
        .from('restaurant_info')
        .select()
        .limit(1);
    if (rows.isEmpty) return const RestaurantInfo();
    return RestaurantInfo.fromMap(rows.first);
  }

  Future<void> update(RestaurantInfo info) async {
    await supabase.from('restaurant_info').update(info.toMap()).eq('id', 1);
  }
}
