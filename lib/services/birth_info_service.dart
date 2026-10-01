import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BirthInfo {
  final DateTime dateTime;
  final String location;

  const BirthInfo({required this.dateTime, required this.location});
}

class ChartCache {
  final String sunSign, sunSidereal;
  final String moonSign, moonSidereal, moonPhase;
  final double siderealMoonLon;
  final Map<String, String> planetSigns, planetDegrees;

  const ChartCache({
    required this.sunSign, required this.sunSidereal,
    required this.moonSign, required this.moonSidereal,
    required this.moonPhase, required this.siderealMoonLon,
    required this.planetSigns, required this.planetDegrees,
  });
}

class BirthInfoService {
  static const _keyDateTime = 'birth_datetime';
  static const _keyLocation = 'birth_location';
  static const _keyChartCache = 'birth_chart_cache';

  static Future<void> save(BirthInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDateTime, info.dateTime.toIso8601String());
    await prefs.setString(_keyLocation, info.location);
  }

  static Future<BirthInfo?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dtStr = prefs.getString(_keyDateTime);
    if (dtStr == null) return null;
    return BirthInfo(
      dateTime: DateTime.parse(dtStr),
      location: prefs.getString(_keyLocation) ?? '',
    );
  }

  static Future<void> saveChart(ChartCache cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyChartCache, jsonEncode({
      'sunSign': cache.sunSign,
      'sunSidereal': cache.sunSidereal,
      'moonSign': cache.moonSign,
      'moonSidereal': cache.moonSidereal,
      'moonPhase': cache.moonPhase,
      'siderealMoonLon': cache.siderealMoonLon,
      'planetSigns': cache.planetSigns,
      'planetDegrees': cache.planetDegrees,
    }));
  }

  static const _expectedPlanets = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto'];

  static Future<ChartCache?> loadChart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyChartCache);
    if (raw == null) return null;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final signs = Map<String, String>.from(m['planetSigns']);
    // If cache is missing planets, discard it so we re-fetch a complete chart
    if (!_expectedPlanets.every((p) => signs.containsKey(p))) {
      await prefs.remove(_keyChartCache);
      return null;
    }
    return ChartCache(
      sunSign: m['sunSign'],
      sunSidereal: m['sunSidereal'],
      moonSign: m['moonSign'],
      moonSidereal: m['moonSidereal'],
      moonPhase: m['moonPhase'],
      siderealMoonLon: m['siderealMoonLon'],
      planetSigns: signs,
      planetDegrees: Map<String, String>.from(m['planetDegrees']),
    );
  }

  static Future<void> clearChart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyChartCache);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDateTime);
    await prefs.remove(_keyLocation);
    await prefs.remove(_keyChartCache);
  }
}
