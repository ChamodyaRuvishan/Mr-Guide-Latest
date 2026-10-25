import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../config/api_config.dart';
import '../models/place.dart';
import '../services/map_service.dart';
import '../services/place_service.dart';
import '../services/search_history_service.dart';
import '../widgets/place_details_sheet.dart';

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
  bool _isTripRoute = false;
  final List<Place> _destinations = [];
  String _sortBy = 'relevance'; // 'relevance', 'distance', 'rating'
  String _selectedCategory = 'all';
  bool _optimizingRoute = false;

  // Start location
  LatLng? _startLocation;
  String _startLocationName = '';
  List<Place> _startSearchResults = [];
  bool _showStartSearch = false;
  bool _gettingLocation = false;

  // Map
  LatLng _mapCenter = LatLng(ApiConfig.defaultLat, ApiConfig.defaultLng);
  bool _mapReady = false;
  VoidCallback? _pendingMapAction;

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
        _moveMapTo(_startLocation!, zoom: 13);
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
    _moveMapTo(_startLocation!, zoom: 11);
  }

  Future<void> _searchPlaces(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    await SearchHistoryService.addRecentSearch(normalizedQuery);

    setState(() {
      _searchLoading = true;
      _searchStatus = 'Searching places in Sri Lanka...';
      _places = [];
      _selectedPlace = null;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
      _isTripRoute = false;
    });

    try {
      // Parallel fetch from backend DB and map geocoding service
      final responses = await Future.wait([
        PlaceService.searchBackendPlaces(normalizedQuery),
        MapService.searchPlaces(normalizedQuery),
      ]);

      final backendPlaces = responses[0];
      final mapPlaces = responses[1];

      // Merge results avoiding duplicate coordinates
      final combined = <Place>[...backendPlaces];
      for (final p in mapPlaces) {
        final exists = combined.any((cp) =>
            cp.id == p.id ||
            (cp.name.toLowerCase() == p.name.toLowerCase() &&
                (cp.lat - p.lat).abs() < 0.01 &&
                (cp.lng - p.lng).abs() < 0.01));
        if (!exists) {
          combined.add(p);
        }
      }

      setState(() {
        _places = combined;
        _searchLoading = false;
        if (combined.isNotEmpty) {
          _searchStatus =
              'Found ${combined.length} place${combined.length != 1 ? 's' : ''} in Sri Lanka';
          _mapCenter = LatLng(combined[0].lat, combined[0].lng);
          _fitBoundsToPlaces();
        } else {
          _searchStatus = 'No places found for "$query" in Sri Lanka';
        }
      });

      _enrichRatings(combined);
    } catch (e) {
      // Fallback
      final fallbackResults = await MapService.searchPlaces(normalizedQuery);
      setState(() {
        _places = fallbackResults;
        _searchLoading = false;
        if (fallbackResults.isNotEmpty) {
          _searchStatus = 'Found ${fallbackResults.length} places';
          _fitBoundsToPlaces();
        } else {
          _searchStatus = 'No places found for "$query"';
        }
      });
    }
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    if (category == 'all') {
      if (_searchController.text.trim().isNotEmpty) {
        _searchPlaces(_searchController.text.trim());
      } else {
        _searchNearbyCategory('all');
      }
    } else {
      _searchNearbyCategory(category);
    }
  }

  Future<void> _searchNearbyCategory(String category) async {
    setState(() {
      _searchLoading = true;
      _searchStatus = 'Discovering $category in Sri Lanka...';
      _places = [];
      _selectedPlace = null;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
      _isTripRoute = false;
    });

    final targetLat = _startLocation?.latitude ?? _mapCenter.latitude;
    final targetLng = _startLocation?.longitude ?? _mapCenter.longitude;

    try {
      List<Place> results = await PlaceService.getNearbyPlaces(
        lat: targetLat,
        lng: targetLng,
        radius: 60,
        category: category == 'all' ? null : category,
      );

      if (results.isEmpty && category != 'all') {
        results = await MapService.searchPlaces('$category Sri Lanka', limit: 12);
      }

      setState(() {
        _places = results;
        _searchLoading = false;
        if (results.isNotEmpty) {
          _searchStatus = 'Found ${results.length} places for $category';
          _fitBoundsToPlaces();
        } else {
          _searchStatus = 'No nearby places found for $category';
        }
      });

      _enrichRatings(results);
    } catch (_) {
      setState(() {
        _searchLoading = false;
        _searchStatus = 'Failed to load places for $category';
      });
    }
  }

  void _enrichRatings(List<Place> placesList) {
    for (var i = 0; i < placesList.length && i < 10; i++) {
      final p = placesList[i];
      if (p.rating == null) {
        final idToFetch = p.googlePlaceId ?? (p.id.isNotEmpty ? p.id : null);
        if (idToFetch != null) {
          PlaceService.getPlaceReviews(idToFetch).then((rev) {
            if (mounted && rev['avgRating'] != null && (rev['avgRating'] as num) > 0) {
              setState(() {
                final idx = _places.indexWhere((x) => x.id == p.id);
                if (idx != -1) {
                  _places[idx] = _places[idx].copyWith(
                    rating: (rev['avgRating'] as num).toDouble(),
                    userRatingsTotal: rev['totalCount'] as int?,
                  );
                }
              });
            }
          });
        }
      }
    }
  }

  List<Place> get _sortedPlaces {
    if (_places.isEmpty) return [];
    final list = List<Place>.from(_places);

    if (_sortBy == 'distance' && _startLocation != null) {
      list.sort((a, b) {
        final distA = MapService.calculateDistance(
          _startLocation!.latitude,
          _startLocation!.longitude,
          a.lat,
          a.lng,
        );
        final distB = MapService.calculateDistance(
          _startLocation!.latitude,
          _startLocation!.longitude,
          b.lat,
          b.lng,
        );
        return distA.compareTo(distB);
      });
    } else if (_sortBy == 'rating') {
      list.sort((a, b) {
        final rA = a.rating ?? 0.0;
        final rB = b.rating ?? 0.0;
        return rB.compareTo(rA);
      });
    }
    return list;
  }

  void _openPlaceDetails(Place place) {
    setState(() => _selectedPlace = place);
    PlaceDetailsSheet.show(
      context,
      place: place,
      onGetDirections: () => _getDirections(place),
      onToggleTrip: () {
        if (_destinations.any((d) => d.id == place.id)) {
          _removeDestination(place);
        } else {
          _addDestination(place);
        }
      },
    );
  }

  Future<void> _optimizeTripRoute() async {
    if (_startLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your starting location first'),
        ),
      );
      setState(() => _showStartSearch = true);
      return;
    }
    if (_destinations.length < 2) return;

    setState(() => _optimizingRoute = true);

    final startPlace = Place(
      id: 'start',
      name: _startLocationName,
      lat: _startLocation!.latitude,
      lng: _startLocation!.longitude,
      address: '',
      type: 'start',
    );

    final optimized = await PlaceService.optimizeRoute(
      destinations: _destinations,
      startLocation: startPlace,
    );

    setState(() => _optimizingRoute = false);

    if (optimized != null && optimized.isNotEmpty) {
      setState(() {
        _destinations.clear();
        _destinations.addAll(optimized);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route optimized for shortest travel distance!'),
            backgroundColor: Color(0xFF00C853),
          ),
        );
      }
      _buildTripRoute();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not optimize route')),
        );
      }
    }
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
    _moveMapTo(_startLocation!, zoom: 13);
  }

  Future<void> _getDirections(Place place) async {
    if (_startLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your starting location first'),
        ),
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
      _isTripRoute = false;
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
      _runMapAction(() {
        final bounds = LatLngBounds.fromPoints(routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      });
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
      _isTripRoute = false;
    });
  }

  void _clearTrip() {
    setState(() {
      _destinations.clear();
      _selectedPlace = null;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
      _isTripRoute = false;
    });
  }

  void _addDestination(Place place) {
    if (_destinations.any((d) => d.id == place.id)) return;
    setState(() => _destinations.add(place));
  }

  void _removeDestination(Place place) {
    setState(() => _destinations.removeWhere((d) => d.id == place.id));
  }

  String _destinationLabel(int index) {
    final code = 'A'.codeUnitAt(0) + index + 1;
    if (code <= 'Z'.codeUnitAt(0)) {
      return String.fromCharCode(code);
    }
    return '${index + 1}';
  }

  Future<void> _buildTripRoute() async {
    if (_startLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your starting location first'),
        ),
      );
      setState(() => _showStartSearch = true);
      return;
    }

    if (_destinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one destination to build a trip'),
        ),
      );
      return;
    }

    setState(() {
      _selectedPlace = null;
      _routeLoading = true;
      _route = null;
      _routeDistance = null;
      _routeDuration = null;
      _directions = [];
      _isTripRoute = true;
    });

    final points = [
      [_startLocation!.latitude, _startLocation!.longitude],
      ..._destinations.map((d) => [d.lat, d.lng]),
    ];

    final result = await MapService.getMultiRoute(
      points: points,
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

      _runMapAction(() {
        final bounds = LatLngBounds.fromPoints(routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
        );
      });
    } else {
      setState(() {
        _routeLoading = false;
        _isTripRoute = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not calculate trip route')),
        );
      }
    }
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
                    child: const Icon(
                      Icons.expand_less,
                      color: Color(0xFFFFD700),
                    ),
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
        onMapReady: () {
          _mapReady = true;
          final action = _pendingMapAction;
          _pendingMapAction = null;
          if (action != null) {
            try {
              action();
            } catch (_) {}
          }
        },
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

            // Trip destination markers
            ..._destinations.asMap().entries.map((entry) {
              final i = entry.key;
              final place = entry.value;
              return Marker(
                point: LatLng(place.lat, place.lng),
                width: 36,
                height: 36,
                child: _buildMarker(
                  const Color(0xFF2979FF),
                  _destinationLabel(i),
                ),
              );
            }),

            // Search result markers
            ..._sortedPlaces.asMap().entries.map((entry) {
              final i = entry.key;
              final place = entry.value;
              final isSelected = _selectedPlace?.id == place.id;
              return Marker(
                point: LatLng(place.lat, place.lng),
                width: 36,
                height: 36,
                child: GestureDetector(
                  onTap: () => _openPlaceDetails(place),
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
          borderRadius: const BorderRadius.only(
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Transform.rotate(
            angle: 0.785,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSearchBar() {
    final categories = [
      {'id': 'all', 'label': 'All Places', 'icon': Icons.explore},
      {'id': 'attraction', 'label': 'Attractions', 'icon': Icons.attractions},
      {'id': 'beach', 'label': 'Beaches', 'icon': Icons.beach_access},
      {'id': 'restaurant', 'label': 'Food & Cafe', 'icon': Icons.restaurant},
      {'id': 'hotel', 'label': 'Hotels', 'icon': Icons.hotel},
      {'id': 'temple', 'label': 'Temples & Heritage', 'icon': Icons.account_balance},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B2838).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
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
                      strokeWidth: 2,
                      color: Color(0xFFFFD700),
                    ),
                  ),
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
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final cat = categories[idx];
              final isSelected = _selectedCategory == cat['id'];
              return GestureDetector(
                onTap: () {
                  final catId = cat['id'] as String;
                  if (_selectedCategory == catId && catId != 'all') {
                    _selectCategory('all');
                  } else {
                    _selectCategory(catId);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFCC00)
                        : const Color(0xFF1B2838).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFFCC00)
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        size: 14,
                        color: isSelected
                            ? const Color(0xFF0A1020)
                            : const Color(0xFFFFCC00),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF0A1020)
                              : Colors.white,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
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

          // Trip Planner
          _buildTripPlannerSection(),
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
                  color: _places.isNotEmpty
                      ? Colors.greenAccent
                      : Colors.white54,
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
                  Text(
                    'Search for places in Sri Lanka',
                    style: TextStyle(color: Colors.white54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Try: "Sigiriya", "Galle Fort", "Colombo"',
                    style: TextStyle(color: Colors.white30, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Results Sorting Bar
          if (_places.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Text(
                    'Sort:',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip('relevance', 'Relevance'),
                  const SizedBox(width: 6),
                  _buildSortChip('distance', 'Nearest'),
                  const SizedBox(width: 6),
                  _buildSortChip('rating', 'Top Rated'),
                ],
              ),
            ),

          ..._sortedPlaces.asMap().entries.map((entry) {
            final i = entry.key;
            final place = entry.value;
            return _buildPlaceCard(i, place);
          }),
        ],
      ),
    );
  }

  Widget _buildSortChip(String id, String label) {
    final isSelected = _sortBy == id;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFCC00).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFCC00)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFFCC00) : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
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
            Text(
              'Your Starting Point',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _startLocationName,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showStartSearch = true),
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 12),
                  ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location,
                    color: const Color(0xFF00C853),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _gettingLocation ? 'Getting...' : 'Use My Location',
                    style: const TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 12,
                    ),
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: _startSearchResults.map((result) {
                  return ListTile(
                    dense: true,
                    title: Text(
                      result.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      result.address,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
            Text(
              'Travel Mode',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                  if (_isTripRoute && _destinations.isNotEmpty) {
                    _buildTripRoute();
                  } else if (_selectedPlace != null && _startLocation != null) {
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
                      Icon(
                        mode['icon'] as IconData,
                        color: isActive
                            ? const Color(0xFFFFD700)
                            : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode['label'] as String,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFFFFD700)
                              : Colors.white38,
                          fontSize: 11,
                        ),
                      ),
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

  Widget _buildTripPlannerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.route, color: Colors.white54, size: 18),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Route Planning',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_destinations.isNotEmpty)
              GestureDetector(
                onTap: _clearTrip,
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_destinations.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Text(
              'Add destinations from search results using the + button.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _destinations.asMap().entries.map((entry) {
              final i = entry.key;
              final place = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _destinationLabel(i),
                      style: const TextStyle(
                        color: Color(0xFF2979FF),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeDestination(place),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        if (_destinations.length >= 2) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _optimizingRoute ? null : _optimizeTripRoute,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFD700),
                side: const BorderSide(color: Color(0xFFFFD700)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _optimizingRoute
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFFD700),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                _optimizingRoute
                    ? 'Optimizing Stops...'
                    : 'Optimize Route (Shortest Path)',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _destinations.isEmpty ? null : _buildTripRoute,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.alt_route, size: 18),
            label: Text(
              _destinations.isEmpty
                  ? 'Add destinations to build trip'
                  : 'Build trip route (${_destinations.length})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    final List<Widget> stopRows = [
      Row(
        children: [
          _endpointBadge('A', const Color(0xFF00C853)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _startLocationName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    ];

    if (_isTripRoute) {
      for (final entry in _destinations.asMap().entries) {
        stopRows.add(
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _endpointBadge(
                  _destinationLabel(entry.key),
                  const Color(0xFF2979FF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (_selectedPlace != null) {
      stopRows.add(
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              _endpointBadge('B', const Color(0xFF2979FF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedPlace?.name ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4285F4).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map, color: Color(0xFF4285F4), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isTripRoute ? 'Trip Details' : 'Route Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isTripRoute ? _clearTrip : _clearRoute,
                child: const Icon(Icons.close, color: Colors.white38, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...stopRows,
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
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
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
              Text(
                'Turn-by-turn',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
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
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      step.instruction,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${step.distance} km',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
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
    final isInTrip = _destinations.any((d) => d.id == place.id);
    String? distance;
    if (_startLocation != null) {
      distance = MapService.calculateDistance(
        _startLocation!.latitude,
        _startLocation!.longitude,
        place.lat,
        place.lng,
      ).toStringAsFixed(1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2979FF).withValues(alpha: 0.15)
            : const Color(0xFF111B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2979FF)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openPlaceDetails(place),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (place.address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            place.address,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Badges & Actions row
              Row(
                children: [
                  if (place.rating != null && place.rating! > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFCC00),
                            size: 13,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFFFFCC00),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          if (place.userRatingsTotal != null &&
                              place.userRatingsTotal! > 0)
                            Text(
                              ' (${place.userRatingsTotal})',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (distance != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white38,
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$distance km',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  // Info & Reviews button
                  OutlinedButton.icon(
                    onPressed: () => _openPlaceDetails(place),
                    icon: const Icon(Icons.reviews_outlined, size: 14),
                    label: const Text('Details', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFCC00),
                      side: BorderSide(
                        color: const Color(0xFFFFCC00).withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Directions button
                  ElevatedButton.icon(
                    onPressed: () => _getDirections(place),
                    icon: const Icon(Icons.directions, size: 14),
                    label: const Text('Go', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Trip add/remove button
                  GestureDetector(
                    onTap: () {
                      if (isInTrip) {
                        _removeDestination(place);
                      } else {
                        _addDestination(place);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: isInTrip
                            ? const Color(0xFF00C853).withValues(alpha: 0.2)
                            : const Color(0xFFFFD700).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isInTrip
                              ? const Color(0xFF00C853)
                              : const Color(0xFFFFD700),
                        ),
                      ),
                      child: Icon(
                        isInTrip ? Icons.check : Icons.add,
                        size: 16,
                        color: isInTrip
                            ? const Color(0xFF00C853)
                            : const Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
