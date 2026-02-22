class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final String type;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.type,
  });
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
