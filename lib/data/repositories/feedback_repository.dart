import '../models/feedback_review.dart';
import '../supabase_client.dart';

/// Customer feedback: submitted reviews for the showcase, plus the admin inbox.
class FeedbackRepository {
  /// Published reviews shown to everyone on the home showcase.
  Future<List<FeedbackReview>> fetchPublished() async {
    final rows = await supabase
        .from('feedback_reviews')
        .select()
        .eq('kind', FeedbackKind.review.name)
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(20);
    return rows.map(FeedbackReview.fromMap).toList();
  }

  /// Every feedback row (admin inbox; RLS gates to admins only).
  Future<List<FeedbackReview>> fetchAll() async {
    final rows = await supabase
        .from('feedback_reviews')
        .select()
        .order('created_at', ascending: false);
    return rows.map(FeedbackReview.fromMap).toList();
  }

  /// Anyone can submit feedback; it lands unpublished in the admin inbox.
  Future<void> submit(FeedbackReview review) async {
    await supabase.from('feedback_reviews').insert(review.toMap());
  }

  Future<void> togglePublish(FeedbackReview review) async {
    await supabase
        .from('feedback_reviews')
        .update({'is_published': !review.isPublished}).eq('id', review.id);
  }

  Future<void> delete(String id) async {
    await supabase.from('feedback_reviews').delete().eq('id', id);
  }
}
