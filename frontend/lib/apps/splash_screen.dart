import 'package:flutter/material.dart';
import '../apps/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToRegister();
  }

  void _navigateToRegister() async {
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    // var screenHeight = mediaQuery.size.height;
    var screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4D8FAC),
              Color(0xFF88C1E4),
              Color(0xFFB8E0F9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: screenWidth * 0.35,
                height: screenWidth * 0.35,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFF4D8FAC).withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(const Color(0xFF4D8FAC)),
                ),
              ),
              Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              // Icon bayangan di belakang
              Positioned(
                right: screenWidth * 0.07,
                bottom: screenWidth * 0.07,
                child: Icon(
                  Icons.chat_outlined,
                  size: screenWidth * 0.2,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFF4D8FAC),
                      Color(0xFF88C1E4),
                      Color(0xFFB8E0F9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.chat_outlined,
                  size: screenWidth * 0.2,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.white, blurRadius: 5)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
