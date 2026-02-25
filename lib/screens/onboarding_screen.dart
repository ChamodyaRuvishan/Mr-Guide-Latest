import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.location_on,
      color: const Color(0xFFFFC107),
      title: "Welcome to Mr.Guide",
      message: "Your personal tour guide. Discover places, plan trips, and explore with confidence.",
    ),
    OnboardingPage(
      icon: Icons.explore,
      color: const Color(0xFFFFD54F),
      title: "Discover Tours",
      message: "Browse curated tours and experiences for popular destinations.",
    ),
    OnboardingPage(
      icon: Icons.map,
      color: const Color(0xFFFFB300),
      title: "Nearby Places",
      message: "Find nearby attractions, restaurants and landmarks with ease.",
    ),
    OnboardingPage(
      icon: Icons.event,
      color: const Color(0xFFFFC400),
      title: "Plan Your Trip",
      message: "Create and save itineraries for upcoming travels and day trips.",
    ),
    OnboardingPage(
      icon: Icons.offline_pin,
      color: const Color(0xFFFFB74D), // An amber/orange shade
      title: "Offline Maps",
      message: "Seamlessly navigate without internet by saving maps offline.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (_currentPage == _pages.length - 1) {
      await _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkip() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/role_selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Dark background
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _currentPage == _pages.length - 1 ? null : _onSkip,
                child: Text(
                  _currentPage == _pages.length - 1 ? "" : "Skip",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      foregroundColor: const Color(0xFF0D1B2A),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing Icon Container
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.8),
                  page.color.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 60),
          
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Message
          Text(
            page.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });
}
