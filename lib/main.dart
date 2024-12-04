import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'astro_service.dart';

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

class AstroDataScreen extends StatefulWidget {
  const AstroDataScreen({super.key});

  @override
  State<AstroDataScreen> createState() => _AstroDataScreenState();
}

class _AstroDataScreenState extends State<AstroDataScreen> {
  String _response = "Loading Astro data...";
  String _moonPhaseHtml = "";

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
      final String astrologySign = _getAstrologySign(adjustedLongitude);

      setState(() {
        _response = '''
          Moon Phase: $moonPhase
          Moon Longitude: $moonLongitude°
          Sun Longitude: $sunLongitude°
          Adjusted Longitude (Tropical): $adjustedLongitude°
          Astrology Sign: $astrologySign
        ''';

        _moonPhaseHtml = _generateMoonPhaseHtml(moonPhase);
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
      print('Error during Fetch: $e');
    }
  }

  double adjustToTropical(double longitude, double ayanamsa) {
    double adjustedLongitude = longitude - ayanamsa;
    if (adjustedLongitude < 0) {
      adjustedLongitude += 360;
    }
    return adjustedLongitude;
  }

  String _getAstrologySign(double longitude) {
    if (longitude >= 0 && longitude < 30) return 'Aries';
    if (longitude >= 30 && longitude < 60) return 'Taurus';
    if (longitude >= 60 && longitude < 90) return 'Gemini';
    if (longitude >= 90 && longitude < 120) return 'Cancer';
    if (longitude >= 120 && longitude < 150) return 'Leo';
    if (longitude >= 150 && longitude < 180) return 'Virgo';
    if (longitude >= 180 && longitude < 210) return 'Libra';
    if (longitude >= 210 && longitude < 240) return 'Scorpio';
    if (longitude >= 240 && longitude < 270) return 'Sagittarius';
    if (longitude >= 270 && longitude < 300) return 'Capricorn';
    if (longitude >= 300 && longitude < 330) return 'Aquarius';
    if (longitude >= 330 && longitude < 360) return 'Pisces';
    return 'Unknown';
  }

  String _generateMoonPhaseHtml(String moonPhase) {
    const moonCss = '''
      <style>
        .moon-container {
          width: 100px;
          height: 100px;
          position: relative;
        }
        .moon {
          width: 100%;
          height: 100%;
          background-color: #fff;
          border-radius: 50%;
          position: relative;
        }
        .phase {
          position: absolute;
          width: 100%;
          height: 100%;
          background-color: #000;
          border-radius: 50%;
        }
        .new-moon .phase { display: block; }
        .waxing-crescent .phase { clip-path: ellipse(50% 50% at 25% 50%); }
        .first-quarter .phase { clip-path: ellipse(50% 50% at 50% 50%); }
        .waxing-gibbous .phase { clip-path: ellipse(50% 50% at 75% 50%); }
        .full-moon .phase { display: none; }
        .waning-gibbous .phase { clip-path: ellipse(50% 50% at 25% 50%); }
        .last-quarter .phase { clip-path: ellipse(50% 50% at 50% 50%); }
        .waning-crescent .phase { clip-path: ellipse(50% 50% at 75% 50%); }
      </style>
    ''';

    return '''
      $moonCss
      <div class="moon-container $moonPhase">
        <div class="moon">
          <div class="phase"></div>
        </div>
      </div>
    ''';
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
            Html(
              data: _moonPhaseHtml,
            ),
          ],
        ),
      ),
    );
  }
}
