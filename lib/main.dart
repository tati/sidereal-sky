import 'package:flutter/material.dart';
import 'screens/astro_data_screen.dart';

void main() {
  runApp(const AstroDataApp());
}

class AstroDataApp extends StatelessWidget {
  const AstroDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oracle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const AstroDataScreenWithOverlay(),
    );
  }
}

class AstroDataScreenWithOverlay extends StatelessWidget {
  const AstroDataScreenWithOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold background transparent
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE1BEE7), // Light purple
                  Color(0xFF4A148C), // Dark purple
                ],
              ),
            ),
          ),
          const AstroDataScreen(), // Your main app content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/glow_circle_overlay.png',
              fit: BoxFit.cover,
            ),
          ),
          // Positioned widget to place your logo at the bottom right
        ],
      ),
    );
  }
}
