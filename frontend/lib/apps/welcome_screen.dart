import 'package:flutter/material.dart';
import '../apps/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreen createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  bool _isLoading = false;

  void _navigateToRegister() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: screenHeight,
              width: screenWidth,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4D8FAC), // Biru pastel sedang
                    Color(0xFF88C1E4), // Biru pastel terang
                    Color(0xFFB8E0F9), // Biru pastel sangat terang
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.6), 
                          Colors.white.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Icon(
                      Icons.chat_outlined,
                      size: 120,
                      color: Colors.white, // Warna dasar yang akan di-overlay dengan gradasi
                      shadows: [Shadow(color: Colors.white, blurRadius: 5)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ngobar App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enjoy your time with us and\n make new friends',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 1, offset: Offset(1, 2))],
                    ),
                    child: TextButton(
                      onPressed: _navigateToRegister,
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(180, 40),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Color(0xFF4D8FAC),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: screenWidth,
                  height: 8,
                  child: LinearProgressIndicator(
                    backgroundColor: const Color(0xFF4D8FAC).withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D8FAC)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
