// Ví dụ cho profile_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Sign Out'),
          onPressed: () async {
            // Xóa cả backend token và Supabase session
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('backend_token');
            await Supabase.instance.client.auth.signOut();
            
            // Điều hướng về màn hình login
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          },
        ),
      ),
    );
  }
}
