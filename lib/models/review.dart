class Review {
  final String id;
  final String placeId;
  final String userId;
  final String userName; // mapped from `user_name` in backend response
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      placeId: json['place_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      // Backend returns user_name (from User.username join)
      userName: json['user_name'] ??
          json['user']?['username'] ??
          'Anonymous',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      photos: (json['photos'] as List?)
              ?.map((p) => p.toString())
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
