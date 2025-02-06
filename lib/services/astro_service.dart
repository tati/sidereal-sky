import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class AstroService {
  static const String _baseUrl = 'https://ssd.jpl.nasa.gov/api/horizons.api';

  /// Fetches celestial longitude and related data for the Moon and Sun from NASA Horizons API.
  static Future<String> fetchAstroData({
    required String startDate,
    required String endDate,
    String stepSize = '1d',
  }) async {
    try {
      // Build the request URL with geocentric coordinates for Moon and Sun
      final Uri requestUrl = Uri.parse(
        '$_baseUrl?format=json'
        '&COMMAND="301,10"' // Query both Moon (301) and Sun (10)
        '&EPHEM_TYPE=OBSERVER'
        '&CENTER=500@399' // Geocentric perspective
        '&START_TIME=${Uri.encodeComponent(startDate)}'
        '&STOP_TIME=${Uri.encodeComponent(endDate)}'
        '&STEP_SIZE=${Uri.encodeComponent(stepSize)}'
        '&QUANTITIES=2', // Positional data
      );

      log('Request URL: $requestUrl');
      log('response');

      // Send the GET request
      final http.Response response = await http.get(requestUrl);
      log('response test');
      log('response.statusCode $response.statusCode');

      // Handle response
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'HTTP Error: Status Code ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      log('Error during HTTP Request: $e');
      return '{"error":"$e"}';
    }
  }

  /// Parses the celestial longitude and Moon Phase from the Horizons API response.
  static Map<String, dynamic> parseAstroData(String response) {
    try {
      // Extract the "result" field from the JSON response
      final Map<String, dynamic> jsonResponse = jsonDecode(response);
      final String result = jsonResponse['result'];

      // Debug: Print the raw result string
      log('Raw API Result: $result');

      // Parse celestial longitudes for Moon and Sun
      final RegExp longitudeRegex = RegExp(
          r'\d{4}-\w{3}-\d{2}\s+\d{2}:\d{2}\s+([\d.]+)\s+[\d.]+');
      final List<Match> matches = longitudeRegex.allMatches(result).toList();

      log('Matches $matches');

      if (matches.isEmpty) {
        throw Exception('No celestial longitudes found in the response');
      }

      // Extract Moon and Sun longitudes safely
      final double? moonLongitude = matches.isNotEmpty
          ? double.tryParse(matches[0].group(1) ?? '')
          : null;
      final double? sunLongitude = matches.isNotEmpty && matches.length > 1
          ? double.tryParse(matches[1].group(1) ?? '')
          : null;

      // Ensure both values are present
      if (moonLongitude == null || sunLongitude == null) {
        throw Exception('Failed to parse celestial longitudes');
      }

      // Calculate Moon Phase
      final double elongation = (moonLongitude - sunLongitude) % 360;
      final String moonPhase = _calculateMoonPhase(elongation);

      return {
        'moonLongitude': moonLongitude,
        'sunLongitude': sunLongitude,
        'moonPhase': moonPhase,
      };
    } catch (e) {
      log('Error parsing astro data: $e');
      return {};
    }
  }

  /// Determines the Moon Phase based on the elongation angle.
  static String _calculateMoonPhase(double elongation) {
    log('elongation: $elongation');
    if (elongation < 0) elongation += 360; // Ensure positive elongation

    if (elongation >= 0 && elongation < 22.5) return "New Moon";
    if (elongation >= 22.5 && elongation < 67.5) return "Waxing Crescent";
    if (elongation >= 67.5 && elongation < 112.5) return "First Quarter";
    if (elongation >= 112.5 && elongation < 157.5) return "Waxing Gibbous";
    if (elongation >= 157.5 && elongation < 202.5) return "Full Moon";
    if (elongation >= 202.5 && elongation < 247.5) return "Waning Gibbous";
    if (elongation >= 247.5 && elongation < 292.5) return "Last Quarter";
    if (elongation >= 292.5 && elongation < 337.5) return "Waning Crescent";
    
    return "Unknown Moon Phase";
  }

}
