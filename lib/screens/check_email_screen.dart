import 'package:flutter/material.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
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
                    child: const Icon(Icons.face, color: Color(0xFF00C49F), size: 40),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Check Email',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Please check your email for the instructions on how to reset your password.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Minh họa bức thư (Có thể thay bằng Image.asset nếu có file)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        size: 100,
                        color: Color(0xFF00C49F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Quay về màn hình login (Xóa hết stack cũ)
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(text: 'Back to ', style: TextStyle(color: Colors.grey)),
                            TextSpan(text: 'Sign In', style: TextStyle(color: Color(0xFF00C49F), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
