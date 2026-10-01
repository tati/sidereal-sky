import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/astro_service.dart';
import '../services/birth_info_service.dart';
import '../utils/astro_utils.dart';
import '../widgets/moon_phase_widget.dart';
import '../theme/delphi_text_styles.dart';
import 'dart:developer';
import '../services/models/ephemeris_data.dart';
import 'birth_chart_screen.dart';

class AstroDataScreen extends StatefulWidget {
  const AstroDataScreen({super.key});

  @override
  State<AstroDataScreen> createState() => _AstroDataScreenState();
}

class _AstroDataScreenState extends State<AstroDataScreen> {
  String _currentMoonPhase = "";
  double _siderealLongitude = 0;
  String _sunSign = "";
  String _sunLonDisplay = "";
  String _sunSiderealDisplay = "";
  String _moonLonDisplay = "";
  String _moonSiderealDisplay = "";
  String _moonSignName = "";
  bool _hasChart = false;

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

      log("🌙 Start Date: $startDate");
      log("☀️ End Date: $endDate");
      log("⏱️ Step Size: $stepSize");

      final results = await Future.wait([
        AstroService.fetchAstroData(startDate: startDate, endDate: endDate, stepSize: stepSize, command: '301'),
        AstroService.fetchAstroData(startDate: startDate, endDate: endDate, stepSize: stepSize, command: '10'),
      ]);

      final List<EphemerisData> moonData = AstroService.parseAstroData(results[0]);
      final List<EphemerisData> sunData = AstroService.parseAstroData(results[1]);

      if (moonData.isEmpty) throw Exception("Insufficient Moon data for calculation.");
      if (sunData.isEmpty) throw Exception("Insufficient Sun data for calculation.");

      final moonLongitude = moonData[0].longitude;
      final sunLongitude = sunData[0].longitude;
      log("🌙 moonLongitude: $moonLongitude");
      log("☀️ sunLongitude: $sunLongitude");

      final double elongation = (moonLongitude - sunLongitude + 360) % 360;
      final String moonPhase = AstroService.calculateMoonPhase(elongation);

      final double ayanamsa = calculateLahiriAyanamsa(DateTime.now());
      final double siderealMoonLon = adjustToSidereal(moonLongitude, ayanamsa);
      final double siderealSunLon = adjustToSidereal(sunLongitude, ayanamsa);
      final String moonSign = getAstrologySign(siderealMoonLon);
      final String sunSign = getAstrologySign(siderealSunLon);

      setState(() {
        _currentMoonPhase = moonPhase;
        _siderealLongitude = siderealMoonLon;
        _sunSign = sunSign;
        _sunLonDisplay = '${sunLongitude.toStringAsFixed(4)}°';
        _sunSiderealDisplay = '${siderealSunLon.toStringAsFixed(4)}°';
        _moonLonDisplay = '${moonLongitude.toStringAsFixed(4)}°';
        _moonSiderealDisplay = '${siderealMoonLon.toStringAsFixed(4)}°';
        _moonSignName = moonSign;
      });
    } catch (e) {
      log('Error during Fetch: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkChart();
  }

  Future<void> _checkChart() async {
    final cache = await BirthInfoService.loadChart();
    if (mounted) setState(() => _hasChart = cache != null);
  }

  String _signImagePath(String sign) {
    const base = 'assets/images/Astrology Signs/';
    const signs = {
      'Aries': 'Aries.png', 'Taurus': 'Taurus.png', 'Gemini': 'Gemini.png',
      'Cancer': 'Cancer.png', 'Leo': 'Leo.png', 'Virgo': 'Virgo.png',
      'Libra': 'Libra.png', 'Scorpio': 'Scorpio.png', 'Sagittarius': 'Sagittarius.png',
      'Capricorn': 'Capricorn.png', 'Aquarius': 'Aquarius.png', 'Pisces': 'Pisces.png',
    };
    return base + (signs[sign] ?? 'Aries.png');
  }

  // Sign glyphs are Image assets — not text — so typography changes don't affect them.
  Widget _signCircle(String label, String sign) {
    return Column(
      children: [
        Text(label, style: delphiUtilityStyle.copyWith(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF080010),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFFDBA54A).withOpacity(0.55), blurRadius: 18, spreadRadius: 3)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Image.asset(
                        _signImagePath(sign),
                        color: const Color(0xFFDBA54A).withOpacity(0.8),
                        colorBlendMode: BlendMode.srcIn,
                      ),
                    ),
                    Image.asset(
                      _signImagePath(sign),
                      color: const Color(0xFFDBA54A),
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    const entries = [
      ('Sidereal', 'The zodiac system based on the actual current positions of the constellations in the sky, rather than the seasons. Delphi uses this system.'),
      ('Sun Longitude', 'The sun\'s raw position in degrees along the ecliptic (the sun\'s apparent path through the sky), measured tropically, before conversion to the sidereal system.'),
      ('Sun Sidereal', 'The sun\'s position in degrees once the sidereal correction (ayanamsa) has been applied, along with the sign that position falls in.'),
      ('Moon Longitude', 'The moon\'s raw position in degrees along the ecliptic, measured tropically, before conversion to the sidereal system.'),
      ('Moon Sidereal', 'The moon\'s position in degrees once the sidereal correction has been applied, along with the sign that position falls in.'),
      ('Moon Phase', 'The moon\'s current stage in its roughly 29 day cycle, based on how much of it is illuminated by the sun as seen from Earth.'),
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A0A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sidereal Sky', style: delphiLabelStyle),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'The main screen displays sidereal positions only. Raw tropical longitudes are included below for transparency and educational purposes.',
                  style: delphiBodyStyle.copyWith(fontSize: 13, color: Colors.white54),
                ),
                const SizedBox(height: 20),
                // Raw calculation data
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D1A52).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Raw Calculations', style: delphiBodyItalicStyle.copyWith(color: const Color(0xFFDBA54A), fontSize: 15)),
                      const SizedBox(height: 10),
                      _rawRow('Sun Longitude', _sunLonDisplay),
                      _rawRow('Sun Sidereal', '$_sunSiderealDisplay ($_sunSign)'),
                      _rawRow('Moon Longitude', _moonLonDisplay),
                      _rawRow('Moon Sidereal', '$_moonSiderealDisplay ($_moonSignName)'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Glossary
                ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.$1, style: delphiBodyItalicStyle.copyWith(color: const Color(0xFFDBA54A))),
                      const SizedBox(height: 4),
                      Text(e.$2, style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rawRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: delphiBodyStyle.copyWith(fontSize: 13, color: Colors.white54)),
          Text(value, style: delphiBodyStyle.copyWith(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Center(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Sidereal Sky header
                Column(
                  children: [
                    Text(
                      "Sidereal Sky",
                      style: delphiLabelStyle.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(color: const Color(0xFFDBA54A).withOpacity(0.7), blurRadius: 18),
                          Shadow(color: const Color(0xFFDBA54A).withOpacity(0.4), blurRadius: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 220,
                      color: const Color(0xFF4A148C),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your eye on the real sky",
                      style: delphiBodyItalicStyle.copyWith(fontSize: 13, color: Colors.white38),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Moon phase image circle
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF080010),
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
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDBA54A).withOpacity(0.55),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: MoonPhaseWidget(moonPhase: _currentMoonPhase),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Sidereal Longitudes card
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(32, 38, 32, 28),
                      margin: const EdgeInsets.only(top: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D1A52).withOpacity(0.80),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _sunSiderealDisplay.isEmpty
                          ? Text('Loading...', textAlign: TextAlign.center, style: delphiBodyStyle)
                          : RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: delphiBodyStyle,
                                children: [
                                  TextSpan(text: 'Sun: $_sunSiderealDisplay '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Text(_sunSign, style: const TextStyle(fontFamily: 'Maragsa', fontSize: 18, color: Colors.white)),
                                  ),
                                  TextSpan(text: '\nMoon: $_moonSiderealDisplay '),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Text(_moonSignName, style: const TextStyle(fontFamily: 'Maragsa', fontSize: 18, color: Colors.white)),
                                  ),
                                  TextSpan(text: '\nMoon Phase: $_currentMoonPhase'),
                                ],
                              ),
                            ),
                    ),
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
                          child: Text(
                            DateFormat('MMMM d, y').format(DateTime.now()),
                            style: delphiHeaderStyle.copyWith(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Sun and Moon sign glyphs (Image assets, not text)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _signCircle("☀️ Sun", _sunSign.isEmpty ? "Aries" : _sunSign),
                    _signCircle("🌙 Moon", getAstrologySign(_siderealLongitude)),
                  ],
                ),
              ],
            ),
          ),
        ),
          ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://www.delphicollective.org/sidereal-sky')),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontFamily: 'LibreBaskerville',
                      fontSize: 12,
                      color: Colors.white24,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const BirthChartScreen()));
                    _checkChart();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBA54A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFDBA54A).withOpacity(0.5), width: 1),
                    ),
                    child: Text(
                      _hasChart ? '✦ My Chart' : '✦ Chart',
                      style: delphiBodyStyle.copyWith(fontSize: 13, color: const Color(0xFFDBA54A), height: 1.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
