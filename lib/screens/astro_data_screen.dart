import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart'; // Add this line
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // 1. Date at the top with underline
                Column(
                  children: [
                    Text(
                      DateFormat('MMMM d, y').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.indigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 220,
                      color: Colors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 2. Large oval with moon phase name and divider
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[200],
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentMoonPhase.isEmpty ? "Moon Phase" : _currentMoonPhase,
                        style: const TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Decorative divider
                      const Text(
                        "﹌        ⁕        ﹌",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 3. Large circle with moon phase image
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[800],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 140,
                      child: MoonPhaseWidget(moonPhase: _currentMoonPhase),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // 4. Rounded rectangle with tab for "Longitudes"
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main rounded rectangle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      margin: const EdgeInsets.only(top: 18),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[300]?.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _response,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Tab
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[700],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Longitudes",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 5. Astrological Sign label and glyph
                Text(
                  "Astrological Sign",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                // Replace with your actual sign widget or SVG
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      getAstrologySign(0), // Replace 0 with your actual longitude
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
