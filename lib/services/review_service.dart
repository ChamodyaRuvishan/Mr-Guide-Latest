import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/review.dart';

class ReviewService {
  static SupabaseClient get _supabase => SupabaseConfig.client;

  /// Get all reviews for a specific place
  static Future<List<Review>> getReviewsForPlace(String placeId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('place_id', placeId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  /// Submit a new review
  static Future<Map<String, dynamic>> submitReview({
    required String placeId,
    required String placeName,
    required double rating,
    required String comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Please login to submit a review'};
      }

      // Get user profile for username
      final profile = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      final userName = profile?['username'] ?? 'Anonymous';

      final reviewData = {
        'place_id': placeId,
        'place_name': placeName,
        'user_id': user.id,
        'user_name': userName,
        'rating': rating,
        'comment': comment,
      };

      final response = await _supabase
          .from('reviews')
          .insert(reviewData)
          .select()
          .single();

      return {'success': true, 'review': Review.fromJson(response)};
    } on PostgrestException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to submit review. Please try again.',
      };
    }
  }

  /// Update an existing review
  static Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Please login to update a review'};
      }

      final updateData = {'rating': rating, 'comment': comment};

      final response = await _supabase
          .from('reviews')
          .update(updateData)
          .eq('id', reviewId)
          .eq('user_id', user.id)
          .select()
          .single();

      return {'success': true, 'review': Review.fromJson(response)};
    } on PostgrestException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to update review. Please try again.',
      };
    }
  }

  /// Delete a review
  static Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Please login to delete a review'};
      }

      await _supabase
          .from('reviews')
          .delete()
          .eq('id', reviewId)
          .eq('user_id', user.id);

      return {'success': true};
    } on PostgrestException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to delete review. Please try again.',
      };
    }
  }

  /// Get current user's review for a place (to check if they already reviewed)
  static Future<Review?> getUserReviewForPlace(String placeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('reviews')
          .select()
          .eq('place_id', placeId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return Review.fromJson(response);
    } catch (e) {
      print('Error fetching user review: $e');
      return null;
    }
  }

  /// Get average rating for a place
  static Future<Map<String, dynamic>> getPlaceRatingSummary(
    String placeId,
  ) async {
    try {
      final reviews = await getReviewsForPlace(placeId);

      if (reviews.isEmpty) {
        return {'averageRating': 0.0, 'totalReviews': 0};
      }

      final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
      final average = sum / reviews.length;

      return {'averageRating': average, 'totalReviews': reviews.length};
    } catch (e) {
      return {'averageRating': 0.0, 'totalReviews': 0};
    }
  }
}
