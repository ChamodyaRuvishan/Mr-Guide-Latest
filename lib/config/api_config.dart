class ApiConfig {
  // Change this to your backend server URL
  // For Android emulator use 10.0.2.2, for real device use your PC's IP
  static const String baseUrl = 'http://10.0.2.2:3001/api';

  // MapTiler API Key
  static const String mapTilerKey = 'xsEVv6FORhLcPcw7bN85';

  // Map tile URL
  static String get mapTileUrl => mapTilerKey.trim().isEmpty
      ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
      : 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey';

  // Sri Lanka Bounding Box
  static const double slSouth = 5.916;
  static const double slNorth = 9.835;
  static const double slWest = 79.652;
  static const double slEast = 81.879;

  // Default center (Sri Lanka)
  static const double defaultLat = 7.8731;
  static const double defaultLng = 80.7718;

  // Colombo fallback
  static const double colomboLat = 6.9271;
  static const double colomboLng = 79.8612;
}
