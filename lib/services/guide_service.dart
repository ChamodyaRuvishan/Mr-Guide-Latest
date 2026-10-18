import 'api_service.dart';

class GuideService {
  /// Register as a guide (authenticated user required)
  static Future<Map<String, dynamic>> registerGuide(
      Map<String, dynamic> guideData) async {
    try {
      final response = await ApiService.post(
        '/guides/register',
        body: guideData,
      );
      if (response != null) {
        return {
          'success': true,
          'message': response['message'] ?? 'Guide registered successfully',
          'guide': response['guide'],
        };
      }
      return {
        'success': false,
        'error': 'Registration failed with empty response',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
      };
    }
  }

  /// Get current user's guide profile
  static Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await ApiService.get('/guides/me/profile');
      if (response != null && response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all verified guides
  static Future<List<dynamic>> getAllGuides() async {
    try {
      final response = await ApiService.get('/guides/all');
      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get live available guides
  static Future<List<dynamic>> getLiveGuides() async {
    try {
      final response = await ApiService.get('/guides/live');
      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get full guide profile by ID
  static Future<Map<String, dynamic>?> getGuideById(dynamic id) async {
    try {
      final response = await ApiService.get('/guides/$id');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update guide profile
  static Future<Map<String, dynamic>> updateProfile(
      dynamic id, Map<String, dynamic> updates) async {
    try {
      final response = await ApiService.put('/guides/$id', body: updates);
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Toggle guide availability and update location
  static Future<Map<String, dynamic>> updateAvailability(
    dynamic id,
    bool isAvailable, {
    double? lat,
    double? lng,
    double? accuracy,
  }) async {
    try {
      final body = {
        'is_available': isAvailable,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (accuracy != null) 'accuracy': accuracy,
      };
      final response =
          await ApiService.put('/guides/$id/availability', body: body);
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Update guide GPS coordinates
  static Future<Map<String, dynamic>> updateLocation(
    dynamic id,
    double lat,
    double lng, {
    double? accuracy,
    dynamic tripId,
  }) async {
    try {
      final body = {
        'lat': lat,
        'lng': lng,
        if (accuracy != null) 'accuracy': accuracy,
        if (tripId != null) 'trip_id': tripId,
      };
      final response = await ApiService.put('/guides/$id/location', body: body);
      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get fare estimate for distance
  static Future<Map<String, dynamic>?> getFareEstimate(
      dynamic guideId, double distanceKm) async {
    try {
      final response = await ApiService.get(
          '/guides/fare-estimate?guideId=$guideId&distanceKm=$distanceKm');
      if (response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
