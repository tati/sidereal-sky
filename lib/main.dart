import 'package:flutter/material.dart';
import 'screens/astro_data_screen.dart';

const Color delphiBackground = Color(0xFF1a0a2e);

void main() {
  runApp(const AstroDataApp());
}

class AstroDataApp extends StatelessWidget {
  const AstroDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sidereal Sky',
      debugShowCheckedModeBanner: false,
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
          Container(color: delphiBackground),
          const AstroDataScreen(), // Your main app content
          // Positioned widget to place your logo at the bottom right
        ],
      ),
    );
  }
}
