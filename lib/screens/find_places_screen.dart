import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/api_config.dart';
import '../models/place.dart';
import '../services/map_service.dart';
import 'place_detail_screen.dart';

class FindPlacesScreen extends StatefulWidget {
  const FindPlacesScreen({super.key});

  @override
  State<FindPlacesScreen> createState() => _FindPlacesScreenState();
}

class _FindPlacesScreenState extends State<FindPlacesScreen> {
  final _searchController = TextEditingController();
  final _mapController = MapController();

  // State
  List<Place> _places = [];
  Place? _selectedPlace;
  bool _searchLoading = false;
  String _searchStatus = '';

  // Map
  LatLng _mapCenter = LatLng(ApiConfig.defaultLat, ApiConfig.defaultLng);
  bool _mapReady = false;
  VoidCallback? _pendingMapAction;

  // Panel state
  bool _showPanel = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _searchLoading = true;
      _searchStatus = 'Searching in Sri Lanka...';
      _places = [];
      _selectedPlace = null;
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
    _runMapAction(() {
      final bounds = LatLngBounds.fromPoints(
        _places.map((p) => LatLng(p.lat, p.lng)).toList(),
      );
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    });
  }

  void _moveMapTo(LatLng point, {double zoom = 13}) {
    _runMapAction(() {
      _mapController.move(point, zoom);
    });
  }

  void _runMapAction(VoidCallback action) {
    if (_mapReady) {
      try {
        action();
      } catch (_) {}
      return;
    }
    _pendingMapAction = action;
  }

  void _openPlaceDetails(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlaceDetailScreen(place: place)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
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
                    child: const Icon(
                      Icons.expand_less,
                      color: Color(0xFFFFD700),
                    ),
                    onPressed: () => setState(() => _showPanel = true),
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
        onMapReady: () {
          setState(() => _mapReady = true);
          if (_pendingMapAction != null) {
            _pendingMapAction!();
            _pendingMapAction = null;
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: ApiConfig.mapTileUrl,
          additionalOptions: const {'key': ApiConfig.mapTilerKey},
        ),
        // Place markers
        MarkerLayer(
          markers: _places.map((place) {
            final isSelected = _selectedPlace?.id == place.id;
            return Marker(
              point: LatLng(place.lat, place.lng),
              width: isSelected ? 50 : 40,
              height: isSelected ? 50 : 40,
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlace = place),
                child: Icon(
                  Icons.location_on,
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFFF5252),
                  size: isSelected ? 50 : 40,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopSearchBar() {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          ),
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
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search places in Sri Lanka...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onSubmitted: _searchPlaces,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(6),
              child: ElevatedButton(
                onPressed: () => _searchPlaces(_searchController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B2838),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                if (_searchLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  )
                else if (_searchStatus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _searchStatus,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),

                if (_selectedPlace != null) ...[
                  _buildSelectedPlaceCard(),
                  const SizedBox(height: 16),
                ],

                // Places list
                if (_places.isNotEmpty && _selectedPlace == null)
                  ..._places.map((place) => _buildPlaceCard(place)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlaceCard() {
    final place = _selectedPlace!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white38),
                onPressed: () => setState(() => _selectedPlace = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            place.address,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          if (place.type.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                place.type.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openPlaceDetails(place),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View Details & Reviews',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedPlace = place);
          _moveMapTo(LatLng(place.lat, place.lng), zoom: 15);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.address,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.type.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          place.type.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
