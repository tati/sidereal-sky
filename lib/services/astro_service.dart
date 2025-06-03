import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'models/ephemeris_data.dart';

class AstroService {
  static const String _baseUrl = 'https://ssd.jpl.nasa.gov/api/horizons.api';

  static Future<String> fetchAstroData({
    required String startDate,
    required String endDate,
    required String stepSize,
  }) async {
    try {
      log("✅ Fetching the astro data using the NASA JPL Horizons API");
      final Uri requestUrl = Uri.parse(
        '$_baseUrl?format=json'
        '&COMMAND="301"' // Moon (301)
        '&EPHEM_TYPE=OBSERVER'
        '&CENTER=500@399'
        '&START_TIME=${Uri.encodeComponent(startDate)}'
        '&STOP_TIME=${Uri.encodeComponent(endDate)}'
        '&STEP_SIZE=${Uri.encodeComponent(stepSize)}'
        '&QUANTITIES=23',
      );

      log('Request URL: $requestUrl');
      final http.Response response = await http.get(requestUrl);
      log('response.statusCode: ${response.statusCode}');
      log("✅ Astro data has been fetched");
      log('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      log('HTTP Request Error: $e');
      return '{"error":"$e"}';
    }
  }

  static String calculateMoonPhase(double elongation) {
    if (elongation < 0) elongation += 360;
    elongation = elongation % 360;

    if (elongation < 22.5 || elongation >= 337.5) return "New Moon";
    if (elongation >= 22.5 && elongation < 67.5) return "Waxing Crescent";
    if (elongation >= 67.5 && elongation < 112.5) return "First Quarter";
    if (elongation >= 112.5 && elongation < 157.5) return "Waxing Gibbous";
    if (elongation >= 157.5 && elongation < 202.5) return "Full Moon";
    if (elongation >= 202.5 && elongation < 247.5) return "Waning Gibbous";
    if (elongation >= 247.5 && elongation < 292.5) return "Last Quarter";
    if (elongation >= 292.5 && elongation < 337.5) return "Waning Crescent";

    return "Unknown Phase";
  }

  static List<EphemerisData> parseAstroData(String response) {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response);
      final String result = jsonResponse['result'];
      final List<String> lines = LineSplitter.split(result).toList();

      final int soeIndex = lines.indexWhere((line) => line.contains(r'$$SOE'));
      final int eoeIndex = lines.indexWhere((line) => line.contains(r'$$EOE'));

      log("SOE index: $soeIndex");
      log("EOE index: $eoeIndex");

      if (soeIndex == -1 || eoeIndex == -1 || eoeIndex <= soeIndex) {
        log("❌ Could not find valid SOE/EOE markers in response.");
        return [];
      }

      final List<String> dataLines = lines.sublist(soeIndex + 1, eoeIndex);
      final List<EphemerisData> data = [];

      for (final line in dataLines) {
        final parts = line.trim().split(RegExp(r'\s+'));

        if (parts.length < 3 || !RegExp(r'\d{4}-?[A-Za-z]{3}-?\d{2}').hasMatch(parts[0])) {
          log("⚠️ Skipping non-ephemeris line: $line");
          continue;
        }

        final String datePart = '${parts[0]} ${parts[1]}';

        try {
          // Guard against non-numeric longitude
          if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(parts[2])) {
            log("⚠️ Skipping line with invalid longitude: $line");
            continue;
          }

          final double lon = double.parse(parts[2]);
          final double lat = 0.0;
          final double range = 0.0;

          data.add(EphemerisData(
            timestamp: DateTime.parse(_convertToIso(datePart)),
            longitude: lon,
            latitude: lat,
            range: range,
          ));
        } catch (e) {
          log("⚠️ Skipped malformed ephemeris line: $line");
        }
      }

      log("Returning Ephemeris data ${data.length} item(s)");
      return data;
    } catch (e) {
      log('❌ Parse Error: $e');
      return [];
    }
  }

  static String _convertToIso(String dateStr) {
    final months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final parts = dateStr.split(RegExp(r'[-\s]'));
    if (parts.length < 4) {
      throw FormatException("Date string malformed: $dateStr");
    }

    final year = parts[0];
    final month = months[parts[1]]!;
    final day = parts[2].padLeft(2, '0');
    final time = parts[3];

    return '$year-$month-${day}T$time';
  }
}
