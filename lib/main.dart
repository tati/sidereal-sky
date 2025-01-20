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
      title: 'Astro Data Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AstroDataScreen(),
    );
  }
}