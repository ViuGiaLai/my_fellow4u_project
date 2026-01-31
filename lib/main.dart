import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import các trang chính
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';

// Import các trang cho BottomNavigationBar
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ieacrgscsrqtfxzebqdv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllYWNyZ3Njc3JxdGZ4emVicWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyMDQxOTcsImV4cCI6MjA4MDc4MDE5N30.trtd-J93Qr5FuRiW6wL9Mt3znp90pv9FvId5QydgIIM',
   );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      // Quyết định trang ban đầu dựa trên trạng thái đăng nhập
      initialRoute: Supabase.instance.client.auth.currentSession == null ? '/' : '/main',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const MainAppScaffold(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }
}

// WIDGET MỚI: Quản lý BottomNavigationBar và các trang con
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  int _selectedIndex = 0;
  late final StreamSubscription<AuthState> _authSubscription;

  // Danh sách các trang tương ứng với các mục trong BottomNavBar
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(title: 'Trang Chủ'), // Trang 0
    LocationScreen(),               // Trang 1
    MessagesScreen(),               // Trang 2
    NotificationsScreen(),          // Trang 3
    ProfileScreen(),                // Trang 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự kiện đăng xuất để điều hướng người dùng về trang login
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut) {
        // Đảm bảo không có lỗi khi widget đã bị hủy
        if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body sẽ thay đổi dựa trên _selectedIndex
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // Đây là BottomNavigationBar bạn muốn thêm
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Location'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00B167),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Để label luôn hiển thị
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
