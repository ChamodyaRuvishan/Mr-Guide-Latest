import 'package:flutter_test/flutter_test.dart';
import 'package:mr_guide/models/place.dart';

void main() {
  group('Place Model Tests', () {
    test('parses backend PostgreSQL place json correctly', () {
      final json = {
        'id': 'p-101',
        'name': 'Sigiriya Ancient Fortress',
        'lat': 7.9570,
        'lng': 80.7603,
        'address': 'Sigiriya, Central Province, Sri Lanka',
        'type': 'attraction',
        'rating': 4.8,
        'user_ratings_total': 1250,
        'price_level': 2,
        'google_place_id': 'ChIJ_yH3Z2g04joRV6p34_9-wL8',
        'photos': ['https://example.com/sigiriya.jpg'],
        'open_now': true,
      };

      final place = Place.fromJson(json);

      expect(place.id, 'p-101');
      expect(place.name, 'Sigiriya Ancient Fortress');
      expect(place.lat, 7.9570);
      expect(place.lng, 80.7603);
      expect(place.rating, 4.8);
      expect(place.userRatingsTotal, 1250);
      expect(place.googlePlaceId, 'ChIJ_yH3Z2g04joRV6p34_9-wL8');
      expect(place.openNow, true);
      expect(place.photos?.length, 1);
    });

    test('parses Google Places API format with geometry coordinates', () {
      final googleJson = {
        'place_id': 'ChIJFfL279xN4zoR5Ff5wG-wL8',
        'name': 'Galle Dutch Fort',
        'geometry': {
          'location': {
            'lat': 6.0269,
            'lng': 80.2170,
          },
        },
        'formatted_address': 'Church St, Galle 80000, Sri Lanka',
        'types': ['tourist_attraction', 'point_of_interest'],
        'rating': 4.7,
        'user_ratings_total': 890,
      };

      final place = Place.fromJson(googleJson);

      expect(place.name, 'Galle Dutch Fort');
      expect(place.lat, 6.0269);
      expect(place.lng, 80.2170);
      expect(place.googlePlaceId, 'ChIJFfL279xN4zoR5Ff5wG-wL8');
      expect(place.rating, 4.7);
      expect(place.userRatingsTotal, 890);
    });

    test('copyWith updates rating and total count properly', () {
      final original = Place(
        id: '1',
        name: 'Temple of the Tooth',
        lat: 7.2936,
        lng: 80.6413,
        address: 'Kandy',
        type: 'temple',
      );

      final updated = original.copyWith(
        rating: 4.9,
        userRatingsTotal: 3400,
        googlePlaceId: 'google-kandy-1',
      );

      expect(updated.id, '1');
      expect(updated.name, 'Temple of the Tooth');
      expect(updated.rating, 4.9);
      expect(updated.userRatingsTotal, 3400);
      expect(updated.googlePlaceId, 'google-kandy-1');
      expect(updated.lat, 7.2936);
    });
  });
}
