import 'dart:convert';
import 'package:http/http.dart' as http;

class AstroService {
  static const String _apiKey = 'OSZmK3YwxE'; // Replace with your actual API key
  static const String _secretKey = 'Mky2rX9eR2TbbHs8ZBdQ'; // Replace with your actual secret key
  static const String _baseUrl = 'https://api.xmltime.com/astrodata';

  /// Fetches astrological data for a given location, date range, astronomical object, and interval.
  /// This method uses the user/password in the URL for authentication.
  ///
  /// - [placeid]: Location identifier.
  /// - [startDate]: Start date for the data range in YYYY-MM-DD format.
  /// - [endDate]: End date for the data range in YYYY-MM-DD format.
  /// - [object]: Astronomical object (e.g., "sun", "moon").
  /// - [interval]: Data interval (e.g., "hourly", "daily").
  ///
  /// Returns:
  /// - A [Future<String>] containing the response body as a JSON string.
  ///
  /// Throws:
  /// - Exception if the HTTP request fails or the API returns an error.
  static Future<String> fetchAstroData({
    required String placeid,
    required String startDate,
    required String endDate,
    required String object,
    required String interval,
  }) async {
    try {
      // Build the request URL with `accesskey` and `secretkey`
      final Uri requestUrl = Uri.parse(
        '$_baseUrl'
        '?accesskey=${Uri.encodeComponent(_apiKey)}'
        '&secretkey=${Uri.encodeComponent(_secretKey)}'
        '&placeid=${Uri.encodeComponent(placeid)}'
        '&startdt=${Uri.encodeComponent(startDate)}'
        '&enddt=${Uri.encodeComponent(endDate)}'
        '&object=${Uri.encodeComponent(object)}'
        '&interval=${Uri.encodeComponent(interval)}'
        '&version=3',
      );

      print('Request URL: $requestUrl');

      // Send the GET request
      final http.Response response = await http.get(requestUrl);

      // Log response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception(
            'HTTP Error: Status Code ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      print('Error during HTTP Request: $e');
      return '{"version":3,"errors":["$e"]}'; // Return a JSON-like error message
    }
  }
}

void main() async {
  try {
    final result = await AstroService.fetchAstroData(
      placeid: 'norway/oslo', // Example place ID
      startDate: '2024-11-23', // Start date
      endDate: '2024-12-23', // End date
      object: 'moon', // Example object
      interval: 'daily', // Example interval
    );

    print('API Response: $result');
  } catch (e) {
    print('Error: $e');
  }
}
