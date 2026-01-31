// Ví dụ cho profile_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign Out'),
          onPressed: () {
            Supabase.instance.client.auth.signOut();
            // Điều hướng về màn hình login sau khi đăng xuất
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ),
    );
  }
}
