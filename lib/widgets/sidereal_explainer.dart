import 'package:flutter/material.dart';
import '../theme/delphi_text_styles.dart';

const _gold = Color(0xFFDBA54A);
const _purple = Color(0xFF3D1A52);

/// A short, readable explanation of sidereal astrology.
///
/// Used in two places: the "What is sidereal?" screen, and the daily screen's
/// offline view so people get something worthwhile when NASA can't be reached.
class SiderealExplainer extends StatelessWidget {
  const SiderealExplainer({super.key});

  static const List<({String heading, String body})> sections = [
    (
      heading: 'Two zodiacs, one sky',
      body:
          'There are two ways to measure the zodiac. The tropical zodiac, the one '
          'behind most Western horoscopes, starts Aries on the first day of spring, '
          'wherever the stars happen to be. The sidereal zodiac starts Aries where '
          'the stars actually are. Sidereal literally means "of the stars."',
    ),
    (
      heading: 'The wobble that moved the stars',
      body:
          'Earth spins like a top, and like a top it slowly wobbles. One wobble '
          'takes about 26,000 years. Because of it, the first day of spring slides '
          'backward against the stars by about one degree every 72 years. This is '
          'called the precession of the equinoxes.',
    ),
    (
      heading: 'About 24° apart, and counting',
      body:
          'Around 1,700 years ago the two zodiacs lined up. Western astrology kept '
          'its signs tied to the seasons, so they have been drifting away from the '
          'constellations ever since. Today the gap is about 24°, almost a whole '
          'sign. Astrologers call this offset the ayanamsa.',
    ),
    (
      heading: 'What it means for you',
      body:
          'Each sign is 30° wide, so a 24° shift moves most placements back one sign. '
          'If you were born in roughly the first three weeks of your tropical sign, '
          'your sidereal Sun is likely the sign before it. A tropical Leo born in late '
          'July, for example, has a sidereal Sun in Cancer.',
    ),
    (
      heading: 'An old idea, not a new one',
      body:
          'Sidereal astrology is the older tradition. The Babylonian zodiac was '
          'anchored to the stars, and Vedic astrology (Jyotish) in India has used the '
          'sidereal zodiac for around two thousand years. Sidereal Sky uses the Lahiri ayanamsa, the '
          'standard adopted for India\'s national calendar in the 1950s.',
    ),
    (
      heading: 'Where our sky comes from',
      body:
          'Every position in Sidereal Sky is calculated from NASA\'s Jet Propulsion '
          'Laboratory Horizons system, the same public data astronomers and space '
          'missions rely on. We then apply the ayanamsa to show you where each body '
          'sits against the stars.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in sections) _section(s.heading, s.body),
        _example(),
      ],
    );
  }

  Widget _section(String heading, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white70, height: 1.6)),
        ],
      ),
    );
  }

  Widget _example() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _purple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text('Same moment, two zodiacs', style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 14)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _exampleColumn('Tropical', '10° Leo', 'tied to the seasons')),
              Container(width: 1, height: 60, color: Colors.white12),
              Expanded(child: _exampleColumn('Sidereal', '16° Cancer', 'tied to the stars')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exampleColumn(String label, String value, String caption) {
    return Column(
      children: [
        Text(label, style: delphiBodyStyle.copyWith(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 6),
        Text(value, style: delphiBodyStyle.copyWith(fontSize: 17)),
        const SizedBox(height: 4),
        Text(caption, style: delphiBodyItalicStyle.copyWith(fontSize: 11, color: Colors.white38)),
      ],
    );
  }
}
