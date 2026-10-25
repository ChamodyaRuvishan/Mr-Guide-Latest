import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'screens/about_screen.dart';
import 'screens/ai_assistant_screen.dart';
import 'screens/explore_tab_screen.dart';
import 'screens/find_guide_screen.dart';
import 'screens/find_places_screen.dart';
import 'screens/live_trip_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';
import 'screens/search_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/widget_gallery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MrGuideApp());
}

class MrGuideApp extends StatefulWidget {
  const MrGuideApp({super.key});

  @override
  State<MrGuideApp> createState() => _MrGuideAppState();
}

class _MrGuideAppState extends State<MrGuideApp> {
  User? _user;
  int _authRevision = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final revision = _authRevision;
    final user = await AuthService.getCurrentUser();
    if (mounted && revision == _authRevision) {
      setState(() {
        _user = user;
      });
    }
  }

  void _setUser(User user) {
    _authRevision++;
    setState(() => _user = user);
  }

  void _logout() async {
    final revision = ++_authRevision;
    await AuthService.logout();
    if (mounted && revision == _authRevision) {
      setState(() => _user = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/home':
            return MaterialPageRoute(
              builder: (_) => MainScaffold(
                user: _user,
                onLogout: _logout,
                onLogin: _setUser,
              ),
            );
          case '/search':
            final query = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => SearchScreen(initialQuery: query),
            );
          case '/find-places':
            return MaterialPageRoute(builder: (_) => const FindPlacesScreen());
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(onLogin: _setUser),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (_) => RegisterScreen(onLogin: _setUser),
            );
          case '/about':
            return MaterialPageRoute(builder: (_) => const AboutScreen());
          case '/ai-assistant':
            return MaterialPageRoute(builder: (_) => const AiAssistantScreen());
          case '/live-trip':
            return MaterialPageRoute(builder: (_) => const LiveTripScreen());
          case '/guides':
            return MaterialPageRoute(builder: (_) => const FindGuideScreen());
          case '/explore':
            return MaterialPageRoute(builder: (_) => const ExploreTabScreen());
          case '/widget-gallery':
            return MaterialPageRoute(builder: (_) => const WidgetGalleryScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
