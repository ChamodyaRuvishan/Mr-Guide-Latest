import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';
import '../models/place.dart';
import '../services/map_service.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _startSearchController = TextEditingController();
  final _mapController = MapController();

  // State
  List<Place> _places = [];
  Place? _selectedPlace;
  List<LatLng>? _route;
  String? _routeDistance;
  int? _routeDuration;
  List<RouteStep> _directions = [];
  bool _searchLoading = false;
  bool _routeLoading = false;
  String _searchStatus = '';
  String _travelMode = 'car';

  // Start location
  LatLng? _startLocation;
  String _startLocationName = '';
  List<Place> _startSearchResults = [];
  bool _showStartSearch = false;
  bool _gettingLocation = false;

  // Map
  LatLng _mapCenter = LatLng(ApiConfig.defaultLat, ApiConfig.defaultLng);

  // Panel state
  bool _showPanel = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchPlaces(widget.initialQuery!);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        setState(() {
          _startLocation = LatLng(position.latitude, position.longitude);
          _startLocationName = 'Your Current Location';
          _mapCenter = _startLocation!;
          _gettingLocation = false;
        });
      } else {
        _setDefaultLocation();
      }
    } catch (e) {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      _startLocation = LatLng(ApiConfig.colomboLat, ApiConfig.colomboLng);
      _startLocationName = 'Colombo (Default)';
      _searchStatus = 'Location denied. Using Colombo as default start.';
      _gettingLocation = false;
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _searchLoading = true;
      _searchStatus = 'Searching in Sri Lanka...';
      _places = [];
      _selectedPlace = null;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
    });

    final results = await MapService.searchPlaces(query);

    setState(() {
      _places = results;
      _searchLoading = false;
      if (results.isNotEmpty) {
        _searchStatus =
            'Found ${results.length} place${results.length != 1 ? 's' : ''} in Sri Lanka';
        _mapCenter = LatLng(results[0].lat, results[0].lng);
        _fitBoundsToPlaces();
      } else {
        _searchStatus = 'No places found for "$query" in Sri Lanka';
      }
    });
  }

  void _fitBoundsToPlaces() {
    if (_places.isEmpty) return;
    try {
      final bounds = LatLngBounds.fromPoints(
        _places.map((p) => LatLng(p.lat, p.lng)).toList(),
      );
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    } catch (_) {}
  }

  Future<void> _searchStartLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _startSearchResults = []);
      return;
    }

    final results = await MapService.searchPlaces(query, limit: 5);
    setState(() => _startSearchResults = results);
  }

  void _selectStartLocation(Place place) {
    setState(() {
      _startLocation = LatLng(place.lat, place.lng);
      _startLocationName = place.name;
      _startSearchController.text = place.name;
      _startSearchResults = [];
      _showStartSearch = false;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
    });
  }

  Future<void> _getDirections(Place place) async {
    if (_startLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set your starting location first')),
      );
      setState(() => _showStartSearch = true);
      return;
    }

    setState(() {
      _selectedPlace = place;
      _routeLoading = true;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
    });

    final result = await MapService.getRoute(
      startLat: _startLocation!.latitude,
      startLng: _startLocation!.longitude,
      endLat: place.lat,
      endLng: place.lng,
      travelMode: _travelMode,
    );

    if (result != null) {
      final routePoints = (result['routePoints'] as List)
          .map((p) => LatLng(p[0], p[1]))
          .toList();

      setState(() {
        _route = routePoints;
        _routeDistance = result['distance'];
        _routeDuration = result['duration'];
        _directions = result['steps'];
        _routeLoading = false;
      });

      // Fit to route
      try {
        final bounds = LatLngBounds.fromPoints(routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      } catch (_) {}
    } else {
      setState(() => _routeLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not calculate route')),
        );
      }
    }
  }

  void _clearRoute() {
    setState(() {
      _selectedPlace = null;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          _buildMap(),

          // Top Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: _buildTopSearchBar(),
          ),

          // Bottom Panel
          if (_showPanel)
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.08,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return _buildBottomPanel(scrollController);
              },
            ),

          // Toggle panel button
          Positioned(
            bottom: _showPanel ? null : 20,
            top: _showPanel ? null : null,
            right: 16,
            child: _showPanel
                ? const SizedBox()
                : FloatingActionButton.small(
                    backgroundColor: const Color(0xFF1B2838),
                    child:
                        const Icon(Icons.expand_less, color: Color(0xFFFFD700)),
                    onPressed: () => setState(() => _showPanel = true),
                  ),
          ),

          // Loading overlay
          if (_routeLoading)
            const Center(
              child: Card(
                color: Color(0xFF1B2838),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: 8,
      ),
      children: [
        TileLayer(
          urlTemplate: ApiConfig.mapTileUrl,
          maxZoom: 20,
          tileSize: 512,
          zoomOffset: -1,
          userAgentPackageName: 'com.mrguide.app',
        ),

        // Route polyline
        if (_route != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!,
                color: const Color(0xFF4285F4),
                strokeWidth: 5,
              ),
            ],
          ),

        // Markers
        MarkerLayer(
          markers: [
            // Start location marker (green)
            if (_startLocation != null)
              Marker(
                point: _startLocation!,
                width: 36,
                height: 36,
                child: _buildMarker(const Color(0xFF00C853), 'A'),
              ),

            // Search result markers
            ..._places.asMap().entries.map((entry) {
              final i = entry.key;
              final place = entry.value;
              final isSelected = _selectedPlace?.id == place.id;
              return Marker(
                point: LatLng(place.lat, place.lng),
                width: 36,
                height: 36,
                child: GestureDetector(
                  onTap: () => _getDirections(place),
                  child: _buildMarker(
                    isSelected
                        ? const Color(0xFF2979FF)
                        : const Color(0xFFE53935),
                    isSelected ? 'B' : '${i + 1}',
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMarker(Color color, String label) {
    return Transform.rotate(
      angle: -0.785, // -45 degrees
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(0),
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Transform.rotate(
            angle: 0.785,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Search places in Sri Lanka...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: (q) {
                if (q.trim().isNotEmpty) _searchPlaces(q.trim());
              },
            ),
          ),
          if (_searchLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFFFFD700))),
            )
          else
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFFFFD700)),
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _searchPlaces(_searchController.text.trim());
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Start Location Section
          _buildStartLocationSection(),
          const SizedBox(height: 12),

          // Travel Mode
          _buildTravelModeSection(),
          const SizedBox(height: 12),

          // Search Status
          if (_searchStatus.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _places.isNotEmpty
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _searchStatus,
                style: TextStyle(
                  color: _places.isNotEmpty ? Colors.greenAccent : Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),

          // Route Info
          if (_routeDistance != null) _buildRouteInfo(),

          // Directions
          if (_directions.isNotEmpty) _buildDirections(),

          // Results List
          if (_places.isEmpty && !_searchLoading)
            Container(
              padding: const EdgeInsets.all(30),
              child: const Column(
                children: [
                  Icon(Icons.search, color: Colors.white24, size: 48),
                  SizedBox(height: 12),
                  Text('Search for places in Sri Lanka',
                      style: TextStyle(color: Colors.white54)),
                  SizedBox(height: 4),
                  Text('Try: "Sigiriya", "Galle Fort", "Colombo"',
                      style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              ),
            ),

          ..._places.asMap().entries.map((entry) {
            final i = entry.key;
            final place = entry.value;
            return _buildPlaceCard(i, place);
          }),
        ],
      ),
    );
  }

  Widget _buildStartLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on, color: Color(0xFF00C853), size: 18),
            SizedBox(width: 6),
            Text('Your Starting Point',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),

        if (_startLocation != null && !_showStartSearch)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child: Text('A',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_startLocationName,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showStartSearch = true),
                  child: const Text('Change',
                      style: TextStyle(
                          color: Color(0xFFFFD700), fontSize: 12)),
                ),
              ],
            ),
          ),

        if (_showStartSearch || _startLocation == null) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _startSearchController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search location in Sri Lanka...',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              isDense: true,
            ),
            onChanged: _searchStartLocation,
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              _getCurrentLocation();
              setState(() {
                _showStartSearch = false;
                _startSearchController.clear();
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.my_location,
                      color: const Color(0xFF00C853), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _gettingLocation ? 'Getting...' : 'Use My Location',
                    style: const TextStyle(
                        color: Color(0xFF00C853), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          if (_startSearchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2942),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: _startSearchResults.map((result) {
                  return ListTile(
                    dense: true,
                    title: Text(result.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(result.address,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    onTap: () => _selectStartLocation(result),
                  );
                }).toList(),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildTravelModeSection() {
    final modes = [
      {'id': 'car', 'icon': Icons.directions_car, 'label': 'Car'},
      {'id': 'bus', 'icon': Icons.directions_bus, 'label': 'Bus'},
      {'id': 'train', 'icon': Icons.train, 'label': 'Train'},
      {'id': 'walk', 'icon': Icons.directions_walk, 'label': 'Walk'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.white54, size: 18),
            SizedBox(width: 6),
            Text('Travel Mode',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: modes.map((mode) {
            final isActive = _travelMode == mode['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _travelMode = mode['id'] as String);
                  if (_selectedPlace != null && _startLocation != null) {
                    _getDirections(_selectedPlace!);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFFFD700)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(mode['icon'] as IconData,
                          color: isActive
                              ? const Color(0xFFFFD700)
                              : Colors.white38,
                          size: 20),
                      const SizedBox(height: 4),
                      Text(mode['label'] as String,
                          style: TextStyle(
                              color: isActive
                                  ? const Color(0xFFFFD700)
                                  : Colors.white38,
                              fontSize: 11)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF4285F4).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map, color: Color(0xFF4285F4), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Route Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ),
              GestureDetector(
                onTap: _clearRoute,
                child: const Icon(Icons.close, color: Colors.white38, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Endpoints
          Row(
            children: [
              _endpointBadge('A', const Color(0xFF00C853)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(_startLocationName,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _endpointBadge('B', const Color(0xFF2979FF)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(_selectedPlace?.name ?? '',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),

          // Stats
          Row(
            children: [
              _statItem('$_routeDistance', 'km'),
              const SizedBox(width: 20),
              _statItem('$_routeDuration', 'min'),
              const SizedBox(width: 20),
              _statItem(
                _travelMode == 'car'
                    ? 'Car'
                    : _travelMode == 'bus'
                        ? 'Bus'
                        : _travelMode == 'train'
                            ? 'Train'
                            : 'Walk',
                'mode',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _endpointBadge(String label, Color color) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11))),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildDirections() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: Colors.white54, size: 18),
              SizedBox(width: 8),
              Text('Turn-by-turn',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ..._directions.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 10))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(step.instruction,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ),
                  Text('${step.distance} km',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(int index, Place place) {
    final isSelected = _selectedPlace?.id == place.id;
    String? distance;
    if (_startLocation != null) {
      distance = MapService.calculateDistance(
        _startLocation!.latitude,
        _startLocation!.longitude,
        place.lat,
        place.lng,
      ).toStringAsFixed(1);
    }

    return GestureDetector(
      onTap: () => _getDirections(place),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2979FF).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2979FF)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2979FF)
                    : const Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(place.address,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (place.type.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(place.type,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                        ),
                      if (distance != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.location_on,
                            color: Colors.white38, size: 12),
                        const SizedBox(width: 2),
                        Text('$distance km',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
