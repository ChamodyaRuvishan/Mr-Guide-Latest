class ApiConfig {
  // Production Render Backend URL (Default)
  static const String baseUrl = 'https://mrguide-backend.onrender.com/api';

  // --- Local & Remote Development Options ---
  // Option 1: USB Debugging with adb (Run `adb reverse tcp:3001 tcp:3001` in terminal)
  // static const String baseUrl = 'http://127.0.0.1:3001/api';
  //
  // Option 2: Android Emulator (10.0.2.2 maps to host 127.0.0.1)
  // static const String baseUrl = 'http://10.0.2.2:3001/api';
  //
  // Option 3: Physical Device via Local Wi-Fi (Change to your PC's IPv4 address)
  // static const String baseUrl = 'http://192.168.1.X:3001/api';
  //
  // Option 4: Ngrok Tunnel (For testing on physical phone via mobile data)
  // static const String baseUrl = 'https://your-ngrok-subdomain.ngrok-free.app/api';

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
