import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/place.dart';

/// PlaceService — Connects to the live Node.js + PostgreSQL backend for places,
/// reviews, authentic details, and route optimization.
///
/// Mirrors the endpoints used in the MRGUIDE web app:
///   GET  /api/places?search=...
///   GET  /api/places/nearby?lat=...&lng=...&radius=...&sort=...
///   GET  /api/places/google/:id/reviews
///   POST /api/places/google/:id/reviews
///   GET  /api/places/google/:id/authentic-details
///   GET  /api/places/search-authentic?name=...&lat=...&lng=...
///   POST /api/places/optimize-route
class PlaceService {
  /// Search places stored in the backend PostgreSQL database
  static Future<List<Place>> searchBackendPlaces(String query) async {
    try {
      final response = await ApiService.get(
        '/places?search=${Uri.encodeComponent(query)}',
      );
      if (response is List) {
        return response.map((json) => Place.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching backend places: $e');
      return [];
    }
  }

  /// Get nearby places from backend with distance and rating
  static Future<List<Place>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radius = 50,
    String sort = 'distance',
    String? category,
  }) async {
    try {
      final categoryParam = category != null && category.isNotEmpty
          ? '&category=${Uri.encodeComponent(category)}'
          : '';
      final response = await ApiService.get(
        '/places/nearby?lat=$lat&lng=$lng&radius=$radius&sort=$sort$categoryParam',
      );
      if (response is List) {
        return response.map((json) => Place.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting nearby places: $e');
      return [];
    }
  }

  /// Get reviews and average rating for a place
  static Future<Map<String, dynamic>> getPlaceReviews(
      String placeIdOrGoogleId) async {
    try {
      final response = await ApiService.get(
        '/places/google/$placeIdOrGoogleId/reviews',
      );
      if (response is Map<String, dynamic>) {
        return {
          'reviews': response['reviews'] ?? [],
          'avgRating': (response['avgRating'] as num?)?.toDouble() ?? 0.0,
          'totalCount': (response['totalCount'] as num?)?.toInt() ?? 0,
        };
      }

      // Fallback to standard place review endpoint
      final fallback = await ApiService.get('/places/$placeIdOrGoogleId/reviews');
      if (fallback is Map<String, dynamic>) {
        return {
          'reviews': fallback['reviews'] ?? [],
          'avgRating': (fallback['average_rating'] as num?)?.toDouble() ?? 0.0,
          'totalCount': (fallback['total'] as num?)?.toInt() ?? 0,
        };
      }
      return {'reviews': [], 'avgRating': 0.0, 'totalCount': 0};
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return {'reviews': [], 'avgRating': 0.0, 'totalCount': 0};
    }
  }

  /// Submit review for a place (authenticated user required)
  static Future<Map<String, dynamic>> submitReview({
    required String placeIdOrGoogleId,
    required int rating,
    required String comment,
    String? placeName,
    String? placeAddress,
    double? lat,
    double? lng,
    String? category,
  }) async {
    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'error': 'Please login to submit a review'};
      }

      final body = {
        'rating': rating,
        'comment': comment,
        if (placeName != null) 'place_name': placeName,
        if (placeAddress != null) 'place_address': placeAddress,
        if (lat != null) 'place_lat': lat,
        if (lng != null) 'place_lng': lng,
        if (category != null) 'place_category': category,
      };

      final response = await ApiService.post(
        '/places/google/$placeIdOrGoogleId/reviews',
        body: body,
      );

      if (response != null) {
        return {'success': true, 'data': response};
      }
      return {'success': false, 'error': 'Empty response from server'};
    } catch (e) {
      final msg = e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), '');
      return {'success': false, 'error': msg};
    }
  }

  /// Get authentic local tips and businesses for a place
  static Future<Map<String, dynamic>> getAuthenticDetails({
    required String placeIdOrGoogleId,
    String? name,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await ApiService.get(
        '/places/google/$placeIdOrGoogleId/authentic-details',
      );

      List users = [];
      List businesses = [];

      if (response is Map<String, dynamic>) {
        users = response['users'] as List? ?? [];
        businesses = response['businesses'] as List? ?? [];
      }

      // If empty, try fallback search-authentic
      if (users.isEmpty && businesses.isEmpty && name != null) {
        final queryParams = [
          'name=${Uri.encodeComponent(name)}',
          if (lat != null) 'lat=$lat',
          if (lng != null) 'lng=$lng',
        ].join('&');

        final fallback = await ApiService.get('/places/search-authentic?$queryParams');
        if (fallback is Map<String, dynamic>) {
          users = fallback['users'] as List? ?? [];
          businesses = fallback['businesses'] as List? ?? [];
        }
      }

      return {
        'users': users,
        'businesses': businesses,
      };
    } catch (e) {
      debugPrint('Error fetching authentic details: $e');
      return {'users': [], 'businesses': []};
    }
  }

  /// Optimize multi-stop route using backend TSP algorithm
  static Future<List<Place>?> optimizeRoute({
    required List<Place> destinations,
    required Place startLocation,
  }) async {
    try {
      final locationsPayload = [
        {'lat': startLocation.lat, 'lng': startLocation.lng, 'name': startLocation.name},
        ...destinations.map((d) => {'lat': d.lat, 'lng': d.lng, 'name': d.name}),
      ];

      final response = await ApiService.post(
        '/places/optimize-route',
        body: {
          'locations': locationsPayload,
          'startLocation': {
            'lat': startLocation.lat,
            'lng': startLocation.lng,
            'name': startLocation.name,
          },
        },
      );

      if (response != null && response['optimizedRoute'] is List) {
        final optimized = response['optimizedRoute'] as List;
        // Map back to Place objects (skipping start location at index 0)
        final orderedDestinations = <Place>[];
        for (final item in optimized.skip(1)) {
          final itemLat = (item['lat'] as num).toDouble();
          final itemLng = (item['lng'] as num).toDouble();
          final match = destinations.firstWhere(
            (d) =>
                (d.lat - itemLat).abs() < 0.001 &&
                (d.lng - itemLng).abs() < 0.001,
            orElse: () => Place(
              id: item['name'] ?? 'optimized-stop',
              name: item['name'] ?? 'Stop',
              lat: itemLat,
              lng: itemLng,
              address: '',
              type: 'place',
            ),
          );
          orderedDestinations.add(match);
        }
        return orderedDestinations;
      }
      return null;
    } catch (e) {
      debugPrint('Error optimizing route: $e');
      return null;
    }
  }
}
