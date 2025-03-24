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
        scaffoldBackgroundColor: const Color.fromARGB(255, 53, 21, 110),
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
      body: Stack(
        children: [
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
          Positioned(
            bottom: 16, // adjust margin as needed
            right: 16,  // adjust margin as needed
            child: Image.asset(
              'assets/images/logo_transparent.png',
              width: 100, // adjust the size as needed
            ),
          ),
        ],
      ),
    );
  }
}
