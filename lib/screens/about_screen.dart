import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('About Mr. Guide',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Column(
                children: [
                  Text('About Mr. Guide',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Your trusted companion in discovering amazing places',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Mission
            _sectionTitle('Our Mission'),
            const SizedBox(height: 10),
            const Text(
              'At Mr. Guide, we revolutionize travel planning by combining intelligent route optimization with authentic local knowledge. Our platform helps travelers discover hidden gems, plan efficient routes, and make informed decisions based on verified information from local experts and fellow travelers.',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 30),

            // Development Team
            _sectionTitle('Development Team'),
            const SizedBox(height: 8),
            const Text(
              'Faculty of Engineering, University of Ruhuna\nDepartment of Computer Engineering',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),

            _teamMember('HT', 'Herath H.M.T.B', 'EG/2022/5067',
                'Backend Development & Database Design'),
            _teamMember('JT', 'Jayasekara T.H.D.P.U', 'EG/2022/5098',
                'Frontend Development & UI/UX Design'),
            _teamMember('HA', 'Hapuarachchi H.A.C.R', 'EG/2022/5058',
                'Google Maps Integration & API Development'),
            _teamMember('HG', 'Hettiarachchi H.A.K.G', 'EG/2022/5073',
                'Algorithm Development & Route Optimization'),
            const SizedBox(height: 30),

            // Key Features
            _sectionTitle('Key Features'),
            const SizedBox(height: 12),
            _featureItem(Icons.map_outlined, 'Smart Route Planning',
                'TSP algorithm finds the shortest path to visit all destinations'),
            _featureItem(Icons.location_on_outlined, 'Location-Based Search',
                'Find hotels, restaurants, and attractions near any location'),
            _featureItem(Icons.verified_outlined, 'Authentic Details',
                'Verified information from local experts and business owners'),
            _featureItem(Icons.star_outline, 'Community Reviews',
                'Honest reviews and ratings from real travelers'),
            _featureItem(Icons.public_outlined, 'Global Coverage',
                'Support for multiple countries with localized phone numbers'),
            _featureItem(Icons.route_outlined, 'Custom Routes',
                'Route markers for easy visualization'),
            const SizedBox(height: 30),

            // Technology Stack
            _sectionTitle('Technology Stack'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _techCard('Frontend',
                        ['React.js', 'Leaflet Maps', 'React Router', 'Axios'])),
                const SizedBox(width: 12),
                Expanded(
                    child: _techCard('Backend',
                        ['Node.js', 'Express.js', 'Sequelize ORM', 'JWT Auth'])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _techCard('Database',
                        ['PostgreSQL', 'Relational Schema', 'Data Validation'])),
                const SizedBox(width: 12),
                Expanded(
                    child: _techCard(
                        'Mobile', ['Flutter', 'Dart', 'flutter_map', 'Geolocator'])),
              ],
            ),
            const SizedBox(height: 30),

            // Contact
            _sectionTitle('Contact Us'),
            const SizedBox(height: 12),
            _contactItem(Icons.email_outlined, 'mrguide@eng.ruh.ac.lk',
                () => _launchEmail('mrguide@eng.ruh.ac.lk')),
            _contactItem(Icons.location_on_outlined,
                'Faculty of Engineering, University of Ruhuna, Hapugala, Galle, Sri Lanka',
                null),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 20,
            fontWeight: FontWeight.bold));
  }

  static Widget _teamMember(
      String initials, String name, String regNo, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
            child: Text(initials,
                style: const TextStyle(
                    color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(regNo,
                    style:
                        const TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                Text(desc,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _featureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFFD700), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _techCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.white38, size: 6),
                    const SizedBox(width: 8),
                    Flexible(
                        child: Text(item,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static Widget _contactItem(
      IconData icon, String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: onTap != null ? const Color(0xFFFFD700) : Colors.white70,
                      fontSize: 13,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none)),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
