import 'api_service.dart';

/// TripService — handles guide booking/trip lifecycle.
///
/// Mirrors the /api/guide-trips endpoints on the Node.js backend.
class TripService {
  /// Create a new booking request (tourist → guide)
  ///
  /// [guideId]       - ID of the guide to book
  /// [originLat/Lng] - Tourist's current location
  /// [destLat/Lng]   - Requested destination
  /// [distanceKm]    - Pre-computed distance (optional, used for fare estimate)
  static Future<Map<String, dynamic>> bookGuide({
    required dynamic guideId,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? originAddress,
    String? destAddress,
    double? distanceKm,
  }) async {
    try {
      final response = await ApiService.post('/guide-trips', body: {
        'guide_id': guideId,
        'origin_lat': originLat,
        'origin_lng': originLng,
        'dest_lat': destLat,
        'dest_lng': destLng,
        if (originAddress != null) 'origin_address': originAddress,
        if (destAddress != null) 'dest_address': destAddress,
        if (distanceKm != null) 'distance_km': distanceKm,
      });

      if (response != null) {
        return {'success': true, 'trip': response};
      }
      return {'success': false, 'error': 'Booking failed with empty response'};
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), ''),
      };
    }
  }

  /// Get fare estimate before booking
  static Future<Map<String, dynamic>?> getFareEstimate({
    required dynamic guideId,
    required double distanceKm,
  }) async {
    try {
      final response = await ApiService.get(
          '/guide-trips/fare-estimate?guideId=$guideId&distanceKm=$distanceKm');
      if (response is Map<String, dynamic>) return response;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all trips for the current tourist
  static Future<List<dynamic>> getMyTrips({int page = 1}) async {
    try {
      final response =
          await ApiService.get('/guide-trips/my-trips?page=$page');
      if (response != null && response['trips'] is List) {
        return response['trips'] as List;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get a single trip by ID
  static Future<Map<String, dynamic>?> getTripById(dynamic tripId) async {
    try {
      final response = await ApiService.get('/guide-trips/$tripId');
      if (response is Map<String, dynamic>) return response;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Tourist cancels a pending booking
  static Future<Map<String, dynamic>> cancelTrip(dynamic tripId) async {
    try {
      final response =
          await ApiService.post('/guide-trips/$tripId/cancel', body: {});
      return {'success': true, 'data': response};
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), ''),
      };
    }
  }

  /// Confirm QR payment for a trip
  static Future<Map<String, dynamic>> confirmQrPayment(
    dynamic tripId, {
    double? tipAmount,
  }) async {
    try {
      final response = await ApiService.post(
        '/guide-trips/$tripId/pay-qr',
        body: {
          if (tipAmount != null) 'tip_amount': tipAmount,
        },
      );
      return {'success': true, 'data': response};
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), ''),
      };
    }
  }

  /// Submit a review for a guide after a completed trip
  static Future<Map<String, dynamic>> reviewGuide({
    required dynamic guideId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await ApiService.post('/guides/$guideId/review', body: {
        'rating': rating,
        'comment': comment,
      });
      return {'success': true, 'data': response};
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst(RegExp(r'^.*Exception:\s*'), ''),
      };
    }
  }
}
