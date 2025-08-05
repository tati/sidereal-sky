import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/astro_service.dart';
import '../utils/astro_utils.dart';
import '../widgets/moon_phase_widget.dart';
import 'dart:developer';
import '../services/models/ephemeris_data.dart';

class AstroDataScreen extends StatefulWidget {
  const AstroDataScreen({super.key});

  @override
  State<AstroDataScreen> createState() => _AstroDataScreenState();
}

class _AstroDataScreenState extends State<AstroDataScreen> {
  String _response = "Loading Astro data...";
  String _moonPhaseHtml = "";
  String _currentMoonPhase = "";

  Future<void> _fetchData() async {
    try {
      final DateTime now = DateTime.now().toUtc();
      final DateTime start = now.subtract(const Duration(minutes: 1));
      final DateTime end = now.add(const Duration(minutes: 1));

      String formatDateTime(DateTime dt) =>
          dt.toIso8601String().split('.').first + 'Z';

      final String startDate = formatDateTime(start);
      final String endDate = formatDateTime(end);
      final String stepSize = "1m";

      log("\uD83C\uDF19 Start Date: $startDate");
      log("\u2600\uFE0F End Date: $endDate");
      log("\u23F1\uFE0F Step Size: $stepSize");

      final String apiResponse = await AstroService.fetchAstroData(
        startDate: startDate,
        endDate: endDate,
        stepSize: stepSize,
      );

      final List<EphemerisData> astroData = AstroService.parseAstroData(apiResponse);

      if (astroData.isEmpty) {
        throw Exception("Insufficient Moon data for calculation.");
      }

      final moonLongitude = astroData[0].longitude;
      log("\uD83C\uDF19 moonLongitude: $moonLongitude");

      final double elongation = moonLongitude % 360;
      final String moonPhase = AstroService.calculateMoonPhase(elongation);

      // Tropical zodiac: do not adjust with ayanamsa
      final double adjustedLongitude = moonLongitude;
      final String astrologySign = getAstrologySign(adjustedLongitude);

      setState(() {
        _response = '''
Moon Phase: $moonPhase
Moon Longitude: $moonLongitude°
Adjusted Longitude (Tropical): $adjustedLongitude°
Astrology Sign: $astrologySign
''';
        _moonPhaseHtml = generateMoonPhaseHtml(moonPhase);
        _currentMoonPhase = moonPhase;
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
      log('Error during Fetch: $e');
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
      backgroundColor: Colors.transparent, // Allow gradient from parent to show
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              child: MoonPhaseWidget(moonPhase: _currentMoonPhase),
            ),
            Html(data: _moonPhaseHtml),
            Text(
              _response,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
