import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _userRole = 'Traveler';

  String _mapRoleToApi(String uiRole) {
  switch (uiRole) {
    case 'Traveler':
      return 'user';
    case 'Guide':
      return 'guide';
    default:
      return 'user';
  }
}

  bool _isLoading = false;

  final String _apiUrl = 'https://backend-mobile-api-a4n4.onrender.com/api/v1/auth/register';

  Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    // 🔹 Map role UI → API
    final String apiRole = _mapRoleToApi(_userRole);

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'country': _countryController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': apiRole, //  ĐÚNG enum backend
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );

      // Có thể điều hướng sang Login
      Navigator.pushReplacementNamed(context, '/login');

    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            responseData['message'] ?? 'Đăng ký thất bại',
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi kết nối server: $e')),
    );
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
            // Header với màu xanh và logo
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Radio buttons cho vai trò
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Traveler',
                          groupValue: _userRole,
                          activeColor: const Color(0xFF00C49F),
                          onChanged: (value) {
                            setState(() {
                              _userRole = value!;
                            });
                          },
                        ),
                        const Text('Traveler', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: 'Guide',
                          groupValue: _userRole,
                          activeColor: const Color(0xFF00C49F),
                          onChanged: (value) {
                            setState(() {
                              _userRole = value!;
                            });
                          },
                        ),
                        const Text('Guide', style: TextStyle(fontSize: 16)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // First Name & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'First Name',
                            hint: 'Yoo',
                            controller: _firstNameController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Last Name',
                            hint: 'Jin',
                            controller: _lastNameController,
                          ),
                        ),
                      ],
                    ),

                    _buildTextField(
                      label: 'Country',
                      hint: 'Country',
                      controller: _countryController,
                    ),

                    _buildTextField(
                      label: 'Email',
                      hint: 'Type email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),

                    _buildTextField(
                      label: 'Password',
                      hint: 'Type password',
                      controller: _passwordController,
                      isPassword: true,
                      helperText: 'Password has more than 6 letters',
                      validator: (value) {
                        if (value == null || value.length < 6) return 'Mật khẩu phải trên 6 ký tự';
                        return null;
                      },
                    ),

                    _buildTextField(
                      label: 'Confirm Password',
                      hint: '••••••',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      validator: (value) {
                        if (value != _passwordController.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Terms & Conditions
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          children: [
                            TextSpan(text: 'By Signing Up, you agree to our '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(color: Color(0xFF00C49F), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nút Sign Up
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C49F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Link Sign In
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                          // Trong register_screen.dart, phần Link Sign In
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Quay lại trang trước đó (thường là Login)
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF00C49F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    String? helperText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              helperText: helperText,
              helperStyle: const TextStyle(fontSize: 10),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00C49F)),
              ),
            ),
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập $label';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
