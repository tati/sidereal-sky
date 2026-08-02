import 'package:flutter/material.dart';

class MoonPhaseWidget extends StatelessWidget {
  final String moonPhase;

  const MoonPhaseWidget({required this.moonPhase, super.key});

  String _imagePath() {
    switch (moonPhase.toLowerCase()) {
      case 'new moon':        return 'assets/images/new_moon.png';
      case 'waxing crescent': return 'assets/images/waxing_crescent.png';
      case 'first quarter':   return 'assets/images/first_quarter.png';
      case 'waxing gibbous':  return 'assets/images/waxing_gibbous.png';
      case 'full moon':       return 'assets/images/full_moon.png';
      case 'waning gibbous':  return 'assets/images/waning_gibbous.png';
      case 'last quarter':    return 'assets/images/last_quarter.png';
      case 'waning crescent': return 'assets/images/waning_crescent.png';
      default:                return 'assets/images/new_moon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(_imagePath());
  }
}
