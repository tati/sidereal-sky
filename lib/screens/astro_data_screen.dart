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
      final String stepSize = "1m"; // low-cost, precise

      log("🌙 Start Date: $startDate");
      log("☀️ End Date: $endDate");
      log("⏱️ Step Size: $stepSize");

      final String apiResponse = await AstroService.fetchAstroData(
        startDate: startDate,
        endDate: endDate,
        stepSize: stepSize,
      );

      final List<EphemerisData> astroData = AstroService.parseAstroData(apiResponse);

      if (astroData.length < 2) {
        throw Exception("Not enough data points to compute Moon and Sun positions.");
      }

      // Assuming the first two entries are Moon and Sun in order
      final moonLongitude = astroData[0].longitude;
      log("moonLongitude: $moonLongitude");
      final sunLongitude = astroData[1].longitude;
      log("sunLongitude:: $sunLongitude");

      // Calculate elongation and moon phase
      final double elongation = (moonLongitude - sunLongitude) % 360;
      final String moonPhase = AstroService.calculateMoonPhase(elongation);

      // Astrology adjustment
      const double ayanamsa = 23.856;
      final double adjustedLongitude = adjustToTropical(moonLongitude, ayanamsa);
      final String astrologySign = getAstrologySign(adjustedLongitude);

      setState(() {
        _response = '''
Moon Phase: $moonPhase
Moon Longitude: $moonLongitude°
Sun Longitude: $sunLongitude°
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
      backgroundColor: Colors.black,
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
