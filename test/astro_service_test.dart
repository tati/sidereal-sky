import 'package:flutter_test/flutter_test.dart';
import 'package:sidereal_sky/services/astro_service.dart';

import 'jpl_fixture.dart';

void main() {
  group('parseAstroData', () {
    test('reads longitude from the position vector, not the velocity', () {
      // x = 0, y = 1 points to ecliptic longitude 90°.
      final data = AstroService.parseAstroData(jplVectorResponse(x: 0, y: 1.5e8));
      expect(data, hasLength(1));
      expect(data.first.longitude, closeTo(90, 1e-9));
      expect(data.first.latitude, closeTo(0, 1e-9));
      expect(data.first.timestamp, DateTime.parse('2026-11-26T00:00:00'));
    });

    test('handles negative components (third quadrant)', () {
      final data = AstroService.parseAstroData(jplVectorResponse(x: -1e8, y: -1e8));
      expect(data.first.longitude, closeTo(225, 1e-9));
    });

    test('returns empty for an error payload instead of throwing', () {
      expect(AstroService.parseAstroData('{"error":"SocketException: offline"}'), isEmpty);
    });

    test('returns empty for garbage', () {
      expect(AstroService.parseAstroData('<html>503 Service Unavailable</html>'), isEmpty);
    });
  });
}
