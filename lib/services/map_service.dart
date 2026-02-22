import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/place.dart';

class MapService {
  /// Search places using MapTiler Geocoding API (primary)
  static Future<List<Place>> searchPlaces(String query,
      {int limit = 15}) async {
    try {
      final url = Uri.parse(
        'https://api.maptiler.com/geocoding/${Uri.encodeComponent('$query, Sri Lanka')}.json',
      ).replace(queryParameters: {
        'key': ApiConfig.mapTilerKey,
        'bbox':
            '${ApiConfig.slWest},${ApiConfig.slSouth},${ApiConfig.slEast},${ApiConfig.slNorth}',
        'limit': '$limit',
        'language': 'en',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List? ?? [];

        final sriLankaResults = features.where((feature) {
          final coords = feature['geometry']['coordinates'];
          final lng = (coords[0] as num).toDouble();
          final lat = (coords[1] as num).toDouble();
          return lat >= ApiConfig.slSouth &&
              lat <= ApiConfig.slNorth &&
              lng >= ApiConfig.slWest &&
              lng <= ApiConfig.slEast;
        }).toList();

        if (sriLankaResults.isNotEmpty) {
          return sriLankaResults.asMap().entries.map((entry) {
            final i = entry.key;
            final feature = entry.value;
            final coords = feature['geometry']['coordinates'];
            return Place(
              id: feature['id']?.toString() ?? 'place-$i',
              name: feature['text'] ??
                  (feature['place_name']?.toString().split(',')[0] ??
                      'Unknown'),
              lat: (coords[1] as num).toDouble(),
              lng: (coords[0] as num).toDouble(),
              address: feature['place_name'] ?? '',
              type: feature['properties']?['category'] ??
                  (feature['place_type'] is List
                      ? feature['place_type'][0]
                      : 'place'),
            );
          }).toList();
        }
      }

      // Fallback to Nominatim
      return await _searchWithNominatim(query, limit: limit);
    } catch (e) {
      // Fallback to Nominatim
      return await _searchWithNominatim(query, limit: limit);
    }
  }

  /// Fallback search with Nominatim (OpenStreetMap)
  static Future<List<Place>> _searchWithNominatim(String query,
      {int limit = 15}) async {
    try {
      final url =
          Uri.parse('https://nominatim.openstreetmap.org/search').replace(
        queryParameters: {
          'q': '$query, Sri Lanka',
          'format': 'json',
          'addressdetails': '1',
          'limit': '$limit',
          'countrycodes': 'lk',
          'viewbox':
              '${ApiConfig.slWest},${ApiConfig.slNorth},${ApiConfig.slEast},${ApiConfig.slSouth}',
          'bounded': '1',
        },
      );

      final response = await http.get(url, headers: {
        'Accept-Language': 'en',
        'User-Agent': 'MrGuide/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Place(
            id: item['place_id']?.toString() ?? 'place-$i',
            name: item['name'] ??
                item['display_name']?.toString().split(',')[0] ??
                'Unknown',
            lat: double.parse(item['lat'].toString()),
            lng: double.parse(item['lon'].toString()),
            address: item['display_name'] ?? '',
            type: item['type'] ?? item['class'] ?? 'place',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get route from OSRM
  static Future<Map<String, dynamic>?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String travelMode = 'car',
  }) async {
    try {
      String profile = 'driving';
      if (travelMode == 'walk') {
        profile = 'foot';
      } else if (travelMode == 'bike') {
        profile = 'bike';
      }

      final coordinates = '$startLng,$startLat;$endLng,$endLat';
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$profile/$coordinates',
      ).replace(queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final routeData = routes[0];
          final coordinates =
              routeData['geometry']['coordinates'] as List;
          final routePoints = coordinates
              .map((coord) => [
                    (coord[1] as num).toDouble(),
                    (coord[0] as num).toDouble(),
                  ])
              .toList();

          final distanceKm =
              ((routeData['distance'] as num) / 1000).toStringAsFixed(1);
          final durationMin =
              ((routeData['duration'] as num) / 60).round();

          List<RouteStep> steps = [];
          final legs = routeData['legs'] as List?;
          if (legs != null && legs.isNotEmpty) {
            final legSteps = legs[0]['steps'] as List? ?? [];
            steps = legSteps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              return RouteStep(
                id: i,
                instruction: _formatInstruction(step),
                distance:
                    ((step['distance'] as num) / 1000).toStringAsFixed(2),
                duration: ((step['duration'] as num) / 60).round(),
              );
            }).toList();
          }

          return {
            'routePoints': routePoints,
            'distance': distanceKm,
            'duration': durationMin,
            'steps': steps,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String _formatInstruction(Map<String, dynamic> step) {
    final maneuver = step['maneuver'] ?? {};
    final type = maneuver['type'] ?? '';
    final modifier = maneuver['modifier'] ?? '';
    final name = step['name']?.toString().isNotEmpty == true
        ? step['name']
        : 'the road';

    if (type == 'arrive') return 'Arrive at destination';
    if (type == 'depart') return 'Start on $name';
    if (type == 'turn') return 'Turn $modifier onto $name';
    if (type == 'continue') return 'Continue on $name';
    if (type == 'roundabout') return 'Take the roundabout, exit to $name';
    if (type == 'merge') return 'Merge onto $name';
    if (type == 'fork') return 'Take the $modifier fork onto $name';

    return '$type $modifier - $name';
  }

  /// Calculate Haversine distance between two points (km)
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * pi / 180;
}
