import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'models/ephemeris_data.dart';

class AstroService {
  static const String _baseUrl = 'https://ssd.jpl.nasa.gov/api/horizons.api';

  static Future<String> fetchAstroData({
    required String startDate,
    required String endDate,
    String stepSize = '1h',
  }) async {
    try {
      final Uri requestUrl = Uri.parse(
        '$_baseUrl?format=json'
        '&COMMAND="301,10"' // Moon (301) and Sun (10)
        '&EPHEM_TYPE=OBSERVER'
        '&CENTER=500@399'
        '&START_TIME=${Uri.encodeComponent(startDate)}'
        '&STOP_TIME=${Uri.encodeComponent(endDate)}'
        '&STEP_SIZE=${Uri.encodeComponent(stepSize)}'
        '&QUANTITIES=2',
      );

      log('Request URL: $requestUrl');
      final http.Response response = await http.get(requestUrl);
      log('response.statusCode: ${response.statusCode}');
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

      final int startIndex = lines.indexWhere((line) => line.contains(r'$$SOE')) + 1;
      final int endIndex = lines.indexWhere((line) => line.contains(r'$$EOE'));
      final List<String> dataLines = lines.sublist(startIndex, endIndex);

      final List<EphemerisData> data = dataLines.map((line) {
        final parts = line.trim().split(RegExp(r'\s+'));
        final String datePart = '${parts[0]} ${parts[1]}';
        final double lon = double.parse(parts[2]);
        final double lat = double.parse(parts[3]);
        final double range = double.parse(parts[4]);

        return EphemerisData(
          timestamp: DateTime.parse(_convertToIso(datePart)),
          longitude: lon,
          latitude: lat,
          range: range,
        );
      }).toList();

      return data;
    } catch (e) {
      log('Parse Error: $e');
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
    final day = parts[2].padLeft(2, '0'); // just in case
    final time = parts[3];

    return '${year}-${month}-${day}T${time}:00';
  }
}
