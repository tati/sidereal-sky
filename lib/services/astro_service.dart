import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'models/ephemeris_data.dart';

class AstroService {
  static const String _baseUrl = 'https://ssd.jpl.nasa.gov/api/horizons.api';

  static Future<String> fetchAstroData({
    required String startDate,
    required String endDate,
    required String stepSize,
    String command = '301',
  }) async {
    try {
      dev.log("✅ Fetching astro data for COMMAND=$command using NASA JPL Horizons API");
      final Uri requestUrl = Uri.parse(
        '$_baseUrl?format=json'
        '&COMMAND=$command'
        '&EPHEM_TYPE=VECTORS'
        '&CENTER=500@399'
        '&REF_PLANE=ECLIPTIC'
        '&REF_SYSTEM=ICRF'
        '&START_TIME=${Uri.encodeComponent(startDate)}'
        '&STOP_TIME=${Uri.encodeComponent(endDate)}'
        '&STEP_SIZE=${Uri.encodeComponent(stepSize)}'
        '&VEC_TABLE=3',
      );

      dev.log('Request URL: $requestUrl');
      final http.Response response = await http.get(requestUrl);
      dev.log('response.statusCode: ${response.statusCode}');
      dev.log("✅ Astro data has been fetched");

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('HTTP Request Error: $e');
      return '{"error":"$e"}';
    }
  }

  static List<EphemerisData> parseAstroData(String response) {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(response);
      final String result = jsonResponse['result'];
      final List<String> lines = LineSplitter.split(result).toList();

      final int soeIndex = lines.indexWhere((line) => line.contains(r'$$SOE'));
      final int eoeIndex = lines.indexWhere((line) => line.contains(r'$$EOE'));

      dev.log("🔍 SOE index: $soeIndex");
      dev.log("🔍 EOE index: $eoeIndex");

      if (soeIndex == -1 || eoeIndex == -1 || eoeIndex <= soeIndex) {
        dev.log("❌ Could not find valid SOE/EOE markers in response.");
        return [];
      }

      final List<String> dataLines = lines.sublist(soeIndex + 1, eoeIndex);
      final List<EphemerisData> data = [];

      for (int i = 0; i < dataLines.length; i++) {
        final line = dataLines[i];

        final dateMatch = RegExp(r'= A\.D\. (\d{4}-[A-Za-z]{3}-\d{2} \d{2}:\d{2}:\d{2}(?:\.\d+)?)').firstMatch(line);
        if (dateMatch == null) continue;

        final String dateStr = dateMatch.group(1)!;

        // Search for the position vector line in the next few lines.
        // JPL uses "X =" (space before =) for position and "VX=" for velocity,
        // so \bX\s*= correctly matches position X but not VX.
        String? vectorLine;
        for (int j = 1; j <= 5 && i + j < dataLines.length; j++) {
          final candidate = dataLines[i + j];
          if (RegExp(r'\bX\s*=').hasMatch(candidate) &&
              RegExp(r'\bY\s*=').hasMatch(candidate) &&
              RegExp(r'\bZ\s*=').hasMatch(candidate) &&
              !candidate.contains('LT')) {
            vectorLine = candidate;
            break;
          }
        }

        if (vectorLine == null) {
          dev.log("⚠️ Skipping line with missing vector data:\n$line");
          continue;
        }

        final xMatch = RegExp(r'\bX\s*=\s*([-\d.E+]+)').firstMatch(vectorLine);
        final yMatch = RegExp(r'\bY\s*=\s*([-\d.E+]+)').firstMatch(vectorLine);
        final zMatch = RegExp(r'\bZ\s*=\s*([-\d.E+]+)').firstMatch(vectorLine);

        if (xMatch == null || yMatch == null || zMatch == null) {
          dev.log("⚠️ Skipping vector line with missing components:\n$vectorLine");
          continue;
        }

        try {
          final double x = double.parse(xMatch.group(1)!);
          final double y = double.parse(yMatch.group(1)!);
          final double z = double.parse(zMatch.group(1)!);

          final double lon = (atan2(y, x) * 180 / pi + 360) % 360;
          final double lat = (atan2(z, sqrt(x * x + y * y)) * 180 / pi);
          final double range = sqrt(x * x + y * y + z * z);

          final DateTime timestamp = DateTime.parse(_convertToIso(dateStr));

          data.add(EphemerisData(
            timestamp: timestamp,
            longitude: lon,
            latitude: lat,
            range: range,
          ));

          dev.log("✅ Parsed: $timestamp | lon=$lon | lat=$lat | range=$range");
        } catch (e) {
          dev.log("⚠️ Exception parsing vector line: $vectorLine\nReason: $e");
        }
      }

      dev.log("✅ Returning Ephemeris data: ${data.length} item(s)");
      return data;
    } catch (e) {
      dev.log('❌ Parse Error: $e');
      return [];
    }
  }

  static String calculateMoonPhase(double elongation) {
    if (elongation < 0) elongation += 360;
    elongation = elongation % 360;

    if (elongation < 22.5 || elongation >= 337.5) return "New Moon";
    if (elongation < 67.5) return "Waxing Crescent";
    if (elongation < 112.5) return "First Quarter";
    if (elongation < 157.5) return "Waxing Gibbous";
    if (elongation < 202.5) return "Full Moon";
    if (elongation < 247.5) return "Waning Gibbous";
    if (elongation < 292.5) return "Last Quarter";
    return "Waning Crescent";
  }

  static String _convertToIso(String dateStr) {
    final months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };

    final parts = dateStr.split(RegExp(r'[-\s:]'));
    if (parts.length < 5) {
      throw FormatException("Date string malformed: $dateStr");
    }

    final year = parts[0];
    final month = months[parts[1]]!;
    final day = parts[2].padLeft(2, '0');
    final hour = parts[3].padLeft(2, '0');
    final minute = parts[4].padLeft(2, '0');
    final second = parts.length > 5 ? parts[5].padLeft(2, '0') : '00';

    return '$year-$month-${day}T$hour:$minute:$second';
  }
}
