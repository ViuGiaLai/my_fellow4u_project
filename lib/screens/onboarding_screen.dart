import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Colors from the design
  final Color _appGreen = const Color(0xFF00B167);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background is green for the splash page (index 0), white for others
      backgroundColor: _currentPage == 0 ? _appGreen : Colors.white,
      body: Stack(
        children: [
          // 1. Main Content (4 pages: 1 Splash + 3 Onboarding)
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildSplashPage(), // Page 1: Splash
              _buildContentPage(
                index: 1,
                title: 'Find a local guide easily',
                desc: 'With Fellow4U, you can find a local guide for your trip easily and explore the way you want.',
                imageUrl: 'https://res.cloudinary.com/dqe5syxc0/image/upload/v1768121220/Onboarding-01_qpjfon.png',
              ),
              _buildContentPage(
                index: 2,
                title: 'Many tours around the world',
                desc: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                imageUrl: 'https://res.cloudinary.com/dqe5syxc0/image/upload/v1768121337/Onboarding-02_lcusuv.png',
              ),
              _buildContentPage(
                index: 3,
                title: 'Create a trip and get offers',
                desc: 'Fellow4U helps you save time and get offers from hundreds of local guides that suit your trip.',
                imageUrl: 'https://res.cloudinary.com/dqe5syxc0/image/upload/v1768121338/Onboarding-03_rywf2u.png',
              ),
            ],
          ),

          // 2. Skip Button (Visible from the second page onwards)
          if (_currentPage > 0)
            Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

          // 3. Bottom Navigation (Indicators and Button)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page Indicators (Only for onboarding pages, or all 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => _buildIndicator(index)),
                ),
                const SizedBox(height: 30),
                // Action Button
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 3) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage == 0 ? Colors.white : _appGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == 0 ? 'Explore Now' : (_currentPage == 3 ? 'Get Started' : 'Next'),
                      style: TextStyle(
                        color: _currentPage == 0 ? _appGreen : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? (_currentPage == 0 ? Colors.white : _appGreen)
            : (_currentPage == 0 ? const Color.fromRGBO(255,255,255,0.5) : Colors.grey[300]),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Splash Page UI (Page 1)
  Widget _buildSplashPage() {
    return SizedBox.expand(
      child: Image.network(
        'https://res.cloudinary.com/dqe5syxc0/image/upload/v1767662609/Splash_ynkyil.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: _appGreen,
            child: const Center(
              child: Icon(Icons.error, color: Colors.white, size: 50),
            ),
          );
        },
      ),
    );
  }

  // Content Page UI (Pages 2, 3, 4)
  Widget _buildContentPage({
    required int index,
    required String title,
    required String desc,
    required String imageUrl,
  }) {
    return Transform.translate(
      offset: index == 3 ? const Offset(-20, 0) : Offset.zero,
      child: Column(
        children: [
          const SizedBox(height: 60),
          // Image Section
          Expanded(
            flex: index == 2 ? 6 : 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // Shift 3rd onboarding page (index 3) to the left, 1st to the right
              alignment: index == 3
                  ? Alignment.centerLeft
                  : (index == 1 ? Alignment.centerRight : Alignment.center),
              child: Transform.translate(
                offset: index == 1 ? const Offset(12, 0) : Offset.zero,
                child: Image.network(
                  imageUrl,
                  fit: index == 2 ? BoxFit.cover : BoxFit.contain,
                  // Make 2nd onboarding page (index 2) a bit larger
                  width: index == 2 ? MediaQuery.of(context).size.width * 0.9 : null,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                  },
                ),
              ),
            ),
          ),
          // Text Section
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
