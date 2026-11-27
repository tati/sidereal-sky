import 'dart:convert';

/// Builds a response shaped like NASA JPL Horizons' VECTORS output
/// (format=json, VEC_TABLE=3) with a single position.
String jplVectorResponse({required double x, required double y, double z = 0}) {
  String e(double v) => v.toStringAsExponential(15).toUpperCase();
  final result = '''
*******************************************************************************
Ephemeris / API_USER Thu Nov 26 12:00:00 2026 Pasadena, USA      / Horizons
*******************************************************************************
\$\$SOE
2461005.500000000 = A.D. 2026-Nov-26 00:00:00.0000 TDB
 X = ${e(x)} Y = ${e(y)} Z = ${e(z)}
 VX= 1.000000000000000E-01 VY= 1.000000000000000E-01 VZ= 1.000000000000000E-02
 LT= 1.000000000000000E+00 RG= 1.000000000000000E+05 RR= 1.000000000000000E-02
\$\$EOE
*******************************************************************************
''';
  return jsonEncode({
    'signature': {'source': 'NASA/JPL Horizons API', 'version': '1.2'},
    'result': result,
  });
}
