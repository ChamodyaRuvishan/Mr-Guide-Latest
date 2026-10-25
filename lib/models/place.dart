class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String type;
  final double? rating;
  final int? userRatingsTotal;
  final int? priceLevel;
  final String? googlePlaceId;
  final List<String>? photos;
  final bool? openNow;
  final double? distance;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.type,
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    this.googlePlaceId,
    this.photos,
    this.openNow,
    this.distance,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    double latitude = 0.0;
    double longitude = 0.0;

    if (json['geometry'] is Map &&
        (json['geometry'] as Map)['location'] is Map) {
      final loc = (json['geometry'] as Map)['location'] as Map;
      latitude = (loc['lat'] as num?)?.toDouble() ?? 0.0;
      longitude = (loc['lng'] as num?)?.toDouble() ?? 0.0;
    } else {
      latitude = (json['latitude'] ?? json['lat'] as num?)?.toDouble() ?? 0.0;
      longitude = (json['longitude'] ?? json['lng'] as num?)?.toDouble() ?? 0.0;
    }

    final rawPhotos = json['photos'];
    List<String>? photoList;
    if (rawPhotos is List) {
      photoList = rawPhotos.map((p) => p.toString()).toList();
    }

    return Place(
      id: json['id']?.toString() ??
          json['google_place_id']?.toString() ??
          json['place_id']?.toString() ??
          '',
      name: json['name']?.toString() ?? 'Unknown Place',
      lat: latitude,
      lng: longitude,
      address: json['address']?.toString() ??
          json['formatted_address']?.toString() ??
          json['vicinity']?.toString() ??
          '',
      type: json['category']?.toString() ??
          json['type']?.toString() ??
          (json['types'] is List && (json['types'] as List).isNotEmpty
              ? (json['types'] as List).first.toString()
              : 'place'),
      rating: (json['avgRating'] ?? json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['totalCount'] ??
              json['userRatingsTotal'] ??
              json['user_ratings_total'] as num?)
          ?.toInt(),
      priceLevel: (json['price_level'] ?? json['priceLevel'] as num?)?.toInt(),
      googlePlaceId:
          json['google_place_id']?.toString() ?? json['place_id']?.toString(),
      photos: photoList,
      openNow: json['open_now'] as bool? ??
          (json['opening_hours'] is Map
              ? (json['opening_hours'] as Map)['open_now'] as bool?
              : null),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Place copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    String? address,
    String? type,
    double? rating,
    int? userRatingsTotal,
    int? priceLevel,
    String? googlePlaceId,
    List<String>? photos,
    bool? openNow,
    double? distance,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      priceLevel: priceLevel ?? this.priceLevel,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      photos: photos ?? this.photos,
      openNow: openNow ?? this.openNow,
      distance: distance ?? this.distance,
    );
  }
}

class RouteStep {
  final int id;
  final String instruction;
  final String distance;
  final int duration;

  RouteStep({
    required this.id,
    required this.instruction,
    required this.distance,
    required this.duration,
  });
}
