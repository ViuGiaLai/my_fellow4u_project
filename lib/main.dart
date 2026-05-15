import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import các trang chính
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/check_email_signup_screen.dart';

// Import các trang cho BottomNavigationBar
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_trips_app.dart';
import 'screens/ChatHomePage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  final prefs = await SharedPreferences.getInstance();
  final backendToken = prefs.getString('backend_token');
  
  runApp(MyApp(hasBackendToken: backendToken != null));
}

class MyApp extends StatelessWidget {
  final bool hasBackendToken;
  
  const MyApp({super.key, required this.hasBackendToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fellow4U App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B167)),
      ),
      initialRoute: hasBackendToken ? '/main' : '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/check-email-signup': (context) {
        final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return CheckEmailSignupScreen(email: email);
      },
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainAppScaffold(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }
}

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _selectedIndex = 0;
  late final StreamSubscription<AuthState> _authSubscription;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(title: 'Trang Chủ'),
    MyTripsApp(),
    ChatListScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // FIX: Chỉ redirect về login khi signedOut VÀ không còn backend token
    // Tránh trường hợp Supabase fire signedOut khi đang dùng custom backend auth
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedOut) {
        final prefs = await SharedPreferences.getInstance();
        final backendToken = prefs.getString('backend_token');
        if (backendToken == null && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // Hàm logout đúng cách: xóa backend token TRƯỚC, sau đó mới signOut Supabase
  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_token'); // Xóa token trước để tránh trigger sai
    await Supabase.instance.client.auth.signOut(); // Supabase signOut sau
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'My trips'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00B167),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}

// Global logout function for easy access from anywhere
Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('backend_token'); // Xóa token trước để tránh trigger sai
  await Supabase.instance.client.auth.signOut(); // Supabase signOut sau
  if (context.mounted) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}