import 'package:flutter/material.dart';

class MoonPhaseWidget extends StatelessWidget {
  final String moonPhase;

  const MoonPhaseWidget({required this.moonPhase, super.key});

  String getMoonPhaseImage(String moonPhase) {
    switch (moonPhase.toLowerCase()) {
      case 'new moon':
        return 'assets/images/new_moon.png';
      case 'full moon':
        return 'assets/images/full_moon.png';
      default:
        return 'assets/images/default_moon.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(getMoonPhaseImage(moonPhase));
  }
}
