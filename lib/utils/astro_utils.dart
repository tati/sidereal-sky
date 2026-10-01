import 'dart:math';

String generateMoonPhaseHtml(String moonPhase) {
  const moonCss = '''
    <style>
      .moon {
        width: 100px;
        height: 100px;
        background-color: #fff;
        border-radius: 50%;
        border: 2px solid #000;
      }
      .new-moon {
        background-color: #000;
      }
      .full-moon {
        background-color: #fff;
      }
      .waxing-crescent {
        background: radial-gradient(circle, #000 50%, #fff 50%);
      }
      .waning-crescent {
        background: radial-gradient(circle, #fff 50%, #000 50%);
      }
    </style>
  ''';

  return '''
    $moonCss
    <div class="moon $moonPhase"></div>
  ''';
}

String getAstrologySign(double longitude) {
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

double calculateLahiriAyanamsa(DateTime date) {
  // Lahiri ayanamsa: 23.856° at J2000.0, precessing at ~50.3 arcseconds/year
  const double baseAyanamsa = 23.856;
  const double ratePerYear = 50.3 / 3600.0;
  final double yearsSince2000 =
      (date.millisecondsSinceEpoch - DateTime(2000, 1, 1).millisecondsSinceEpoch) /
      (365.25 * 24 * 3600 * 1000);
  return baseAyanamsa + (ratePerYear * yearsSince2000);
}

double adjustToSidereal(double longitude, double ayanamsa) {
  double adjusted = longitude - ayanamsa;
  if (adjusted < 0) adjusted += 360;
  return adjusted;
}

// Parses "lat, lon" from a location string. Returns null if not parseable.
({double lat, double lon})? parseCoordinates(String location) {
  final parts = location.split(',');
  if (parts.length != 2) return null;
  final lat = double.tryParse(parts[0].trim());
  final lon = double.tryParse(parts[1].trim());
  if (lat == null || lon == null) return null;
  return (lat: lat, lon: lon);
}

// Calculates the sidereal Ascendant (rising sign) given UTC birth datetime and coordinates.
String? calculateRisingSign(DateTime utcDt, double latDeg, double lonDeg) {
  // Julian Date
  final a = (14 - utcDt.month) ~/ 12;
  final y = utcDt.year + 4800 - a;
  final m = utcDt.month + 12 * a - 3;
  final jdn = utcDt.day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  final jd = jdn.toDouble() + (utcDt.hour - 12) / 24.0 + utcDt.minute / 1440.0;

  // Greenwich Mean Sidereal Time in degrees
  double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0);
  gmst = ((gmst % 360) + 360) % 360;

  // Local Sidereal Time
  final lst = ((gmst + lonDeg) % 360 + 360) % 360;

  // Obliquity of ecliptic
  const obliquity = 23.4393 * pi / 180;
  final ramc = lst * pi / 180;
  final lat = latDeg * pi / 180;

  // Ascendant ecliptic longitude
  double asc = atan2(-cos(ramc), sin(ramc) * cos(obliquity) + tan(lat) * sin(obliquity));
  asc = asc * 180 / pi;
  if (asc < 0) asc += 360;

  // Apply Lahiri ayanamsa for sidereal
  final ayanamsa = calculateLahiriAyanamsa(utcDt);
  asc = (asc - ayanamsa + 360) % 360;

  return getAstrologySign(asc);
}
