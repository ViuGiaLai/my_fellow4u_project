import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Supabase Google Login Handler
  Future<void> _loginWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login error: $e')),
        );
      }
    }
  }

  // Supabase Facebook Login Handler
  Future<void> _loginWithFacebook() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutter://login-callback',
        scopes: 'public_profile,email',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook login error: $e')),
        );
      }
    }
  }

  // API Login Handler
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final useLocal = dotenv.env['USE_LOCAL'] == 'true';
      final baseUrl = useLocal
          ? dotenv.env['API_URL_LOCAL']
          : dotenv.env['API_URL_PROD'];
      final url = Uri.parse('$baseUrl/auth/login');

      debugPrint("API URL: $baseUrl");
      debugPrint('Login URL: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Login response: ${response.statusCode}');
      debugPrint('Login body: ${response.body}');

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200) {
        bool success = false;
        if (data is Map) {
          success = data['success'] == true || data.containsKey('token') || data.containsKey('accessToken');
        }

        if (success) {
            if (data is Map) {
    final tokenValue = data['token'] ?? data['accessToken'];
    if (tokenValue is String && tokenValue.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backend_token', tokenValue);
        debugPrint('✅ Token saved');
      } catch (e) {
        debugPrint('⚠️ SharedPreferences error (non-fatal): $e');
        // Không return ở đây - vẫn tiếp tục navigate
      }
    }

    // ✅ Đăng nhập Supabase sau khi login backend thành công
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Đăng nhập Supabase thành công');
    } catch (e) {
      debugPrint('⚠️ Supabase login error (có thể user chưa có trong Supabase): $e');
    }
  }

           if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful!')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/main',
      (route) => false,
    );
  }
        } else {
          String errorMessage = 'Login failed';
          if (data is Map) {
            errorMessage = data['error']?.toString() ?? data['message']?.toString() ?? errorMessage;
          } else {
            errorMessage = 'Unexpected response from server';
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error ${response.statusCode}: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với màu xanh và logo từ RegisterScreen
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C49F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(200, 40),
                      bottomRight: Radius.elliptical(200, 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(
                        'https://res.cloudinary.com/dqe5syxc0/image/upload/v1768122766/logo_nxxyai.png',
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Sign In Title
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  const Text(
                    'Welcome back, Yoo Jin',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF00B167),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Email Field
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'yoojin@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  
                  CustomPasswordField(
                    controller: _passwordController,
                    hintText: '••••••',
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Forgot Password',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // Sign In Button
                  CustomButton(
                    text: 'SIGN IN',
                    onPressed: _isLoading ? null : _handleLogin,
                    isLoading: _isLoading,
                    height: 55,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Social Login Divider
                  const Center(
                    child: Text(
                      'or sign in with',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/124/124010.png', _loginWithFacebook),
                      const SizedBox(width: 20),
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/2991/2991148.png', _loginWithGoogle),
                      const SizedBox(width: 20),
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/2111/2111466.png', () {}),
                      const SizedBox(width: 20),
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/124/124011.png', () {}),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Color(0xFF00C49F),
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String iconUrl, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: Image.network(
            iconUrl,
            height: 24,
            width: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline, size: 20),
          ),
        ),
      ),
    );
  }
}