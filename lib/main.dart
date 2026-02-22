import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/about_screen.dart';

void main() {
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  void _setUser(User user) {
    setState(() => _user = user);
  }

  void _logout() async {
    await AuthService.logout();
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          body: const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFD700)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Mr. Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          surface: Color(0xFF1B2838),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B2838),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: _MainScaffold(
        user: _user,
        onLogout: _logout,
        onLogin: _setUser,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/search':
            final query = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => SearchScreen(initialQuery: query),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginScreen(onLogin: _setUser),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (_) => RegisterScreen(onLogin: _setUser),
            );
          case '/about':
            return MaterialPageRoute(
              builder: (_) => const AboutScreen(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => _MainScaffold(
                user: _user,
                onLogout: _logout,
                onLogin: _setUser,
              ),
            );
        }
      },
    );
  }
}

class _MainScaffold extends StatefulWidget {
  final User? user;
  final VoidCallback onLogout;
  final Function(User) onLogin;

  const _MainScaffold({
    required this.user,
    required this.onLogout,
    required this.onLogin,
  });

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const AboutScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mr. Guide',
            style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        backgroundColor: const Color(0xFF1B2838),
        actions: [
          if (widget.user != null) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  'Hi, ${widget.user!.username}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onLogout,
              child: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login',
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Register',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
          ],
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF1B2838),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About'),
        ],
      ),
    );
  }
}
