import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/review.dart';

/// ReviewService — backed by the Node.js backend (Neon PostgreSQL).
///
/// All data is shared with the web app via the same database.
/// Endpoints:
///   GET    /api/places/:placeId/reviews          → list reviews
///   POST   /api/places/:placeId/reviews          → create review (auth required)
///   PUT    /api/places/reviews/:reviewId         → update review (auth required)
///   DELETE /api/places/reviews/:reviewId         → delete review (auth required)
class ReviewService {
  /// Get all reviews for a specific place
  static Future<List<Review>> getReviewsForPlace(String placeId) async {
    try {
      final response = await ApiService.get('/places/$placeId/reviews');
      if (response != null && response['reviews'] is List) {
        return (response['reviews'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  /// Submit a new review (user must be logged in)
  static Future<Map<String, dynamic>> submitReview({
    required String placeId,
    required double rating,
    required String comment,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'Please login to submit a review'};
      }

      final response = await ApiService.post(
        '/places/$placeId/reviews',
        body: {
          'rating': rating.toInt(),
          'comment': comment,
        },
      );

      if (response != null) {
        return {'success': true, 'review': Review.fromJson(response)};
      }
      return {'success': false, 'error': 'Failed to submit review'};
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), '');
      return {'success': false, 'error': msg};
    }
  }

  /// Update an existing review
  static Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'Please login to update a review'};
      }

      final response = await ApiService.put(
        '/places/reviews/$reviewId',
        body: {'rating': rating.toInt(), 'comment': comment},
      );

      if (response != null) {
        return {'success': true, 'review': Review.fromJson(response)};
      }
      return {'success': false, 'error': 'Failed to update review'};
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), '');
      return {'success': false, 'error': msg};
    }
  }

  /// Delete a review
  static Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'Please login to delete a review'};
      }

      await ApiService.delete('/places/reviews/$reviewId');
      return {'success': true};
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), '');
      return {'success': false, 'error': msg};
    }
  }

  /// Get the current user's review for a place (if it exists)
  static Future<Review?> getUserReviewForPlace(String placeId) async {
    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) return null;

      final reviews = await getReviewsForPlace(placeId);
      // The backend returns user_id; we check against the current auth token id
      // by calling /auth/me then comparing
      final meResponse = await ApiService.get('/auth/me');
      if (meResponse == null) return null;

      final currentUserId = meResponse['id']?.toString();
      if (currentUserId == null) return null;

      return reviews.firstWhere(
        (r) => r.userId == currentUserId,
        orElse: () => throw StateError('Not found'),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get average rating summary for a place
  static Future<Map<String, dynamic>> getPlaceRatingSummary(
      String placeId) async {
    try {
      final response = await ApiService.get('/places/$placeId/reviews');
      if (response != null) {
        return {
          'averageRating': (response['average_rating'] ?? 0.0).toDouble(),
          'totalReviews': response['total'] ?? 0,
        };
      }
      return {'averageRating': 0.0, 'totalReviews': 0};
    } catch (e) {
      return {'averageRating': 0.0, 'totalReviews': 0};
    }
  }
}
