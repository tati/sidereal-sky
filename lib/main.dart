/// AstroDataApp.dart
///
/// A Flutter application for fetching and displaying astrological data
/// using the AstroService API.
///
/// ## Overview:
/// - The application consists of a single screen where users can
///   press a button to fetch Astro data.
/// - Data is retrieved using the `AstroService` class, which handles
///   API requests and HMAC authentication.
///
/// ## Structure:
/// - **`AstroDataApp`**: The main application widget.
/// - **`AstroDataScreen`**: The home screen of the app, which includes:
///   - A button to trigger the API call.
///   - A text area to display the fetched data or error messages.
///
/// ## Features:
/// - Displays the response from the AstroService API.
/// - Handles errors gracefully and updates the UI with error messages.
/// - Provides a simple UI with Material Design components.
///
/// ## Usage:
/// Run the application:
/// ```bash
/// flutter run
/// ```
///
/// ## Notes:
/// - Replace the `placeid` parameter with a valid location ID recognized
///   by the AstroService API.
/// - Replace the `object` parameter with the desired astronomical object.
/// - Ensure the AstroService class has been correctly configured with
///   valid API keys and secrets.
///
/// ## Dependencies:
/// - `flutter/material.dart` for the UI.
/// - `astro_service.dart` for API interaction.

import 'package:flutter/material.dart';
import 'astro_service.dart';

void main() {
  runApp(const AstroDataApp());
}

/// The main application widget.
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

/// The main screen for displaying Astro data.
class AstroDataScreen extends StatefulWidget {
  const AstroDataScreen({super.key});

  @override
  State<AstroDataScreen> createState() => _AstroDataScreenState();
}

class _AstroDataScreenState extends State<AstroDataScreen> {
  String _response = "Press the button to fetch Astro data";

  /// Fetches Astro data from the AstroService API.
  ///
  /// Updates the UI with the response or an error message.
  Future<void> _fetchData() async {
    try {
      final data = await AstroService.fetchAstroData(
        placeid: 'norway/oslo', // Replace with a valid placeid
        startDate: DateTime.now().toIso8601String().split('T').first, // Current date
        endDate: DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')
            .first, // Next day
        object: 'sun', // Specify the astronomical object (e.g., "sun", "moon")
      );

      setState(() {
        _response = data;
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
      print('Error during Fetch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astro Data Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _response,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Fetch Astro Data'),
            ),
          ],
        ),
      ),
    );
  }
}
