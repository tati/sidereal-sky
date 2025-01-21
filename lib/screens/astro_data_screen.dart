import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/astro_service.dart';
import '../utils/astro_utils.dart';
import '../widgets/moon_phase_widget.dart';

class AstroDataScreen extends StatefulWidget {
  const AstroDataScreen({super.key});

  @override
  State<AstroDataScreen> createState() => _AstroDataScreenState();
}

class _AstroDataScreenState extends State<AstroDataScreen> {
  String _response = "Loading Astro data...";
  String _moonPhaseHtml = "";
  String _currentMoonPhase = ""; // Store the current moon phase

  Future<void> _fetchData() async {
    try {
      final String startDate = DateTime.now().toIso8601String().split('T').first;
      final String endDate = DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')
          .first;

      final String apiResponse = await AstroService.fetchAstroData(
        startDate: startDate,
        endDate: endDate,
      );

      final Map<String, dynamic> astroData = AstroService.parseAstroData(apiResponse);

      if (astroData.isEmpty) {
        throw Exception("Failed to parse astro data");
      }

      final double moonLongitude = astroData['moonLongitude'];
      final double sunLongitude = astroData['sunLongitude'];
      final String moonPhase = astroData['moonPhase'];

      const double ayanamsa = 23.856;
      final double adjustedLongitude = adjustToTropical(moonLongitude, ayanamsa);
      final String astrologySign = etAstrologygSign(adjustedLongitude);

      setState(() {
        _response = '''
          Moon Phase: $moonPhase
          Moon Longitude: $moonLongitude°
          Sun Longitude: $sunLongitude°
          Adjusted Longitude (Tropical): $adjustedLongitude°
          Astrology Sign: $astrologySign
        ''';

        _moonPhaseHtml = generateMoonPhaseHtml(moonPhase);
        _currentMoonPhase = moonPhase; // Update the current moon phase
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
      print('Error during Fetch: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
            Html(data: _moonPhaseHtml),
            const SizedBox(height: 20),
            MoonPhaseWidget(moonPhase: _currentMoonPhase), // Dynamic moon phase
          ],
        ),
      ),
    );
  }
}
