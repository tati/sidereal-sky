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
      title: 'Moon Beam',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.deepPurple,
      ), 
      home: const AstroDataScreen(),
    );
  }
}