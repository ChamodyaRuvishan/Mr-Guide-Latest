import 'api_service.dart';

class AiService {
  /// Ask Lanka Guide AI for travel suggestions (public or authenticated)
  static Future<Map<String, dynamic>> getTravelSuggestions(
      String question) async {
    try {
      final response = await ApiService.post(
        '/ai/travel-suggest',
        body: {'question': question},
      );
      if (response != null && response is Map<String, dynamic>) {
        return {
          'success': true,
          'suggestions': response['suggestions'] ?? [],
          'fallback': response['fallback'] ?? false,
        };
      }
      return {
        'success': false,
        'error': 'Failed to get suggestions',
        'suggestions': [],
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
        'suggestions': [],
      };
    }
  }

  /// Get AI info about a specific place
  static Future<String?> getPlaceInfo(String name,
      {double? lat, double? lng}) async {
    try {
      final response = await ApiService.post(
        '/ai/place-info',
        body: {
          'name': name,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
      if (response != null && response is Map<String, dynamic>) {
        return response['info'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get AI tips for route
  static Future<String?> getRouteTips({
    required List<Map<String, dynamic>> stops,
    String travelMode = 'car',
    double? totalDistance,
    double? totalDuration,
  }) async {
    try {
      final response = await ApiService.post(
        '/ai/route-tips',
        body: {
          'stops': stops,
          'travelMode': travelMode,
          if (totalDistance != null) 'totalDistance': totalDistance,
          if (totalDuration != null) 'totalDuration': totalDuration,
        },
      );
      if (response != null && response is Map<String, dynamic>) {
        return response['tips'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
