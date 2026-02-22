import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> popularDestinations = [
    {'name': 'Sigiriya', 'query': 'Sigiriya Rock Fortress'},
    {'name': 'Temple of the Tooth', 'query': 'Temple of the Tooth Kandy'},
    {'name': 'Galle Fort', 'query': 'Galle Fort'},
    {'name': 'Yala National Park', 'query': 'Yala National Park'},
    {'name': 'Ella', 'query': 'Ella Sri Lanka'},
    {'name': 'Colombo Hotels', 'query': 'Colombo hotels'},
  ];

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.pushNamed(context, '/search', arguments: query.trim());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Hero Title
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Explore ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Sri Lanka',
                        style: TextStyle(color: Color(0xFFFFD700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover amazing places, find the best routes,\nand plan your perfect journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 30),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16),
                        child:
                            Icon(Icons.search, color: Colors.white54, size: 24),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText:
                                'Search for places, hotels, restaurants...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                          ),
                          onSubmitted: _handleSearch,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(6),
                        child: ElevatedButton(
                          onPressed: () =>
                              _handleSearch(_searchController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                          child: const Text('Search',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Popular Destinations
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Popular Destinations',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: popularDestinations.map((dest) {
                    return ActionChip(
                      label: Text(dest['name']!),
                      labelStyle: const TextStyle(color: Colors.white),
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.1),
                      side: BorderSide(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      onPressed: () => _handleSearch(dest['query']!),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // Feature Cards
                _buildFeatureCard(
                  Icons.map_outlined,
                  'Interactive Maps',
                  'Explore with detailed maps powered by MapTiler',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  Icons.directions_car_outlined,
                  'Route Planning',
                  'Get directions by car, bus, train, or walking',
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  Icons.location_on_outlined,
                  'Find Places',
                  'Search hotels, restaurants, and attractions',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFFD700), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
