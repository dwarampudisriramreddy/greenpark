/// Kinds of customer feedback.
enum FeedbackKind {
  review,
  complaint,
  suggestion;

  String get label => switch (this) {
        FeedbackKind.review => 'Review',
        FeedbackKind.complaint => 'Complaint',
        FeedbackKind.suggestion => 'Suggestion',
      };

  static FeedbackKind fromName(String? name) {
    for (final k in FeedbackKind.values) {
      if (k.name == name) return k;
    }
    return FeedbackKind.review;
  }
}

/// A customer review / complaint / suggestion.
class FeedbackReview {
  final String id;
  final String? customerName;
  final FeedbackKind kind;
  final int rating;
  final String message;
  final String? contact;
  final bool isPublished;
  final DateTime createdAt;

  const FeedbackReview({
    required this.id,
    this.customerName,
    this.kind = FeedbackKind.review,
    this.rating = 5,
    required this.message,
    this.contact,
    this.isPublished = false,
    required this.createdAt,
  });

  factory FeedbackReview.fromMap(Map<String, dynamic> map) => FeedbackReview(
        id: map['id'] as String,
        customerName: map['customer_name'] as String?,
        kind: FeedbackKind.fromName(map['kind'] as String?),
        rating: (map['rating'] as num?)?.toInt() ?? 5,
        message: map['message'] as String,
        contact: map['contact'] as String?,
        isPublished: map['is_published'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        if (id.isNotEmpty) 'id': id,
        'customer_name': customerName,
        'kind': kind.name,
        'rating': rating,
        'message': message,
        'contact': contact,
        'is_published': isPublished,
      };
}
