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
      final String startDate = DateTime.now().toIso8601String().split('T').first;
      final String endDate = DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')
          .first;

      log(startDate);
      log(endDate);

      final String apiResponse = await AstroService.fetchAstroData(
        startDate: startDate,
        endDate: endDate,
      );
      log("Astro data has been fetched");
      log(apiResponse);

      final List<EphemerisData> astroData = AstroService.parseAstroData(apiResponse);

      if (astroData.length < 2) {
        throw Exception("Not enough data points to compute Moon and Sun positions.");
      }

      // Assuming the first two entries are Moon and Sun in order
      final moonLongitude = astroData[0].longitude;
      final sunLongitude = astroData[1].longitude;

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
