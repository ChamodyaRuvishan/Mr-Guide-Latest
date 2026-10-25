import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/user.dart';
import '../widgets/widgets.dart';
import 'about_screen.dart';
import 'explore_tab_screen.dart';
import 'find_guide_screen.dart';
import 'home_screen.dart';

/// MainScaffold — App shell hosting the 4 core tabs and floating bottom navigation bar.
///
/// Tabs:
/// 0: Home (HomeScreen with scrollable HomeHeader)
/// 1: Explore (ExploreTabScreen)
/// [CENTER FAB]: Ask AI (triggers AiAssistantScreen)
/// 2: Find a guide (FindGuideScreen)
/// 3: About (AboutScreen)
class MainScaffold extends StatefulWidget {
  final User? user;
  final VoidCallback onLogout;
  final Function(User) onLogin;

  const MainScaffold({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onLogin,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _onAskAi() {
    Navigator.pushNamed(context, '/ai-assistant');
  }

  void _onOpenLiveTrip() {
    Navigator.pushNamed(context, '/live-trip');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        user: widget.user,
        onLogin: () => Navigator.pushNamed(context, '/login'),
        onRegister: () => Navigator.pushNamed(context, '/register'),
        onLogout: widget.onLogout,
        onOpenLiveTrip: _onOpenLiveTrip,
      ),
      const ExploreTabScreen(isTab: true),
      const FindGuideScreen(isTab: true),
      const AboutScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: (index) => setState(() => _currentIndex = index),
          onAskAi: _onAskAi,
        ),
      ),
    );
  }
}
