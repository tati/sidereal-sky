import 'dart:developer';
import 'package:http/http.dart' as http;

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Log the request details
    log('Request: ${request.method} ${request.url}');
    log('Headers: ${request.headers}');
    if (request is http.Request) {
      log('Body: ${request.body}');
    }

    log('Attempting HTTP GET request...');
    final response = await _inner.send(request);

    // Log the response details
    log('Response: ${response.statusCode}');
    return response;
  }
}
