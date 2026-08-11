import '../models/offer.dart';
import '../supabase_client.dart';

/// Promotional offers.
class OfferRepository {
  Future<List<Offer>> fetch() async {
    final rows = await supabase
        .from('offers')
        .select()
        .order('created_at', ascending: false);
    return rows
        .map(Offer.fromMap)
        .toList();
  }

  Future<List<Offer>> fetchActive() async {
    final all = await fetch();
    return all.where((o) => o.isValid).toList();
  }

  Future<Offer> upsert(Offer offer) async {
    final rows = await supabase
        .from('offers')
        .upsert({...offer.toMap(), if (offer.id.isNotEmpty) 'id': offer.id})
        .select();
    return Offer.fromMap(rows.first);
  }

  Future<void> delete(String id) async {
    await supabase.from('offers').delete().eq('id', id);
  }

  Future<void> toggleActive(Offer offer) async {
    await supabase
        .from('offers')
        .update({'is_active': !offer.isActive}).eq('id', offer.id);
  }

  Future<void> toggleFeatured(Offer offer) async {
    await supabase
        .from('offers')
        .update({'is_featured': !offer.isFeatured}).eq('id', offer.id);
  }
}
