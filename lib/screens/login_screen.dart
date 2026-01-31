import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Primary color from the design
  final Color _appGreen = const Color(0xFF00B167);

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
      // FIX: Thêm scopes cụ thể để tránh lỗi "Invalid Scopes: email"
      // Mặc định Supabase có thể yêu cầu các scope không còn hợp lệ hoặc bị thay đổi bởi Facebook.
      // Đảm bảo bạn đã thêm Use Case "Authentication and Account Creation" trong Facebook Developer Console.
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
      final url = Uri.parse('https://backend-mobile-44v9.onrender.com/api/v1/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Debug: print status and body so you can inspect what the server returns
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
          // many APIs return { success: true } or return token/accessToken on success
          success = data['success'] == true || data.containsKey('token') || data.containsKey('accessToken');
        }

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );
            // Navigate to main screen which contains the bottom navigation
            Navigator.pushReplacementNamed(context, '/main');
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
                  
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'yoojin@gmail.com',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00B167), width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '••••••',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00B167), width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        // Chuyển hướng đến màn hình Forgot Password bằng route đã định nghĩa trong main.dart
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
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _appGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'SIGN IN',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
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
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/124/124010.png', _loginWithFacebook), // FB
                      const SizedBox(width: 20),
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/2991/2991148.png', _loginWithGoogle), // Google
                      const SizedBox(width: 20),
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/2111/2111466.png', () {}), // Kakao
                      const SizedBox(width: 20),
                      _buildSocialButton('https://cdn-icons-png.flaticon.com/512/124/124011.png', () {}), // Line
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
                          // Chuyển hướng đến trang đăng ký bằng tên route đã định nghĩa
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Color(0xFF00B167),
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