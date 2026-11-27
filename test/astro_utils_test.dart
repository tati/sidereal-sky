import 'package:flutter_test/flutter_test.dart';
import 'package:sidereal_sky/services/astro_service.dart';
import 'package:sidereal_sky/utils/astro_utils.dart';

void main() {
  group('getAstrologySign', () {
    test('maps each 30° segment to its sign', () {
      const signs = [
        'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
        'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
      ];
      for (var i = 0; i < 12; i++) {
        expect(getAstrologySign(i * 30.0), signs[i], reason: 'start of ${signs[i]}');
        expect(getAstrologySign(i * 30.0 + 29.999), signs[i], reason: 'end of ${signs[i]}');
      }
    });
  });

  group('calculateLahiriAyanamsa', () {
    test('is about 23.86° at J2000', () {
      expect(calculateLahiriAyanamsa(DateTime(2000, 1, 1)), closeTo(23.856, 0.01));
    });

    test('is about 24.2° in 2026', () {
      expect(calculateLahiriAyanamsa(DateTime(2026, 11, 26)), closeTo(24.23, 0.05));
    });

    test('grows about 1° every 72 years', () {
      final a = calculateLahiriAyanamsa(DateTime(1950, 1, 1));
      final b = calculateLahiriAyanamsa(DateTime(2022, 1, 1));
      expect(b - a, closeTo(1.0, 0.02));
    });
  });

  group('adjustToSidereal', () {
    test('subtracts the ayanamsa', () {
      // The explainer's example: 10° Leo tropical is about 16° Cancer sidereal.
      final sidereal = adjustToSidereal(130, 24.2);
      expect(sidereal, closeTo(105.8, 0.001));
      expect(getAstrologySign(sidereal), 'Cancer');
    });

    test('wraps around 0° Aries', () {
      expect(adjustToSidereal(10, 24.2), closeTo(345.8, 0.001));
      expect(getAstrologySign(adjustToSidereal(10, 24.2)), 'Pisces');
    });
  });

  group('calculateMoonPhase', () {
    test('names the eight phases by Sun–Moon elongation', () {
      expect(AstroService.calculateMoonPhase(0), 'New Moon');
      expect(AstroService.calculateMoonPhase(350), 'New Moon');
      expect(AstroService.calculateMoonPhase(45), 'Waxing Crescent');
      expect(AstroService.calculateMoonPhase(90), 'First Quarter');
      expect(AstroService.calculateMoonPhase(135), 'Waxing Gibbous');
      expect(AstroService.calculateMoonPhase(180), 'Full Moon');
      expect(AstroService.calculateMoonPhase(225), 'Waning Gibbous');
      expect(AstroService.calculateMoonPhase(270), 'Last Quarter');
      expect(AstroService.calculateMoonPhase(315), 'Waning Crescent');
      expect(AstroService.calculateMoonPhase(-90), 'Last Quarter');
    });
  });
}
