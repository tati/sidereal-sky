import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../theme/delphi_text_styles.dart';
import '../services/birth_info_service.dart';
import '../services/astro_service.dart';
import '../utils/astro_utils.dart';
import '../widgets/moon_phase_widget.dart';

const _entitlementId = 'sidereal_pro';

const _background = Color(0xFF1a0a2e);
const _gold = Color(0xFFDBA54A);
const _purple = Color(0xFF3D1A52);

const _planetSymbols = {
  'Sun': '☀️', 'Moon': '🌙', 'Mercury': '☿', 'Venus': '♀',
  'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄', 'Uranus': '♅',
  'Neptune': '♆', 'Pluto': '♇',
};

const _signSymbols = {
  'Aries': '♈', 'Taurus': '♉', 'Gemini': '♊', 'Cancer': '♋',
  'Leo': '♌', 'Virgo': '♍', 'Libra': '♎', 'Scorpio': '♏',
  'Sagittarius': '♐', 'Capricorn': '♑', 'Aquarius': '♒', 'Pisces': '♓',
};

const _sunSignText = {
  'Aries': 'Bold and direct, you lead with instinct before overthinking. You\'re energized by challenge and allergic to waiting around. When you want something, you go after it immediately, and you\'d rather make a mistake moving forward than stall out being careful. People are drawn to your confidence, even when it ruffles feathers.',
  'Taurus': 'Steady and grounded, you build things that last. Comfort and consistency aren\'t boring to you, they\'re the foundation everything else stands on. You move at your own pace, and no amount of pressure speeds you up once you\'ve decided how something should go. Once you commit to a person, a project, or a path, you rarely let go of it easily.',
  'Gemini': 'Quick-minded and endlessly curious, you\'re happiest juggling ideas and conversations. Variety keeps you alive, and routine without novelty wears you down fast. You pick up new skills and interests quickly, often moving on before anyone else has caught up. People come to you when they want something explained in a way that actually makes sense.',
  'Cancer': 'Deeply feeling and protective, you lead with intuition and care. Home, literal or emotional, matters more to you than most people realize. You remember details about the people you love and show up for them in quiet, consistent ways. Underneath a soft exterior is someone who will defend the people they care about fiercely.',
  'Leo': 'Warm, expressive, and magnetic, you\'re built to be seen. You give generously, and you expect loyalty in return. There\'s a natural confidence in how you carry yourself, even in rooms where you don\'t know anyone. When you commit to something, you go all in, and you want the people around you to match that energy.',
  'Virgo': 'Precise and quietly devoted, you notice what others miss. You show love through fixing, improving, and showing up reliably. You hold yourself to high standards, sometimes higher than anyone else would expect of you. People trust you because you follow through, even on the small things nobody else would bother with.',
  'Libra': 'Charming and fair-minded, you seek balance in everything: relationships, aesthetics, decisions. Conflict genuinely unsettles you, and you\'ll go out of your way to smooth things over before they escalate. You have a natural sense for what looks and feels right, and people often lean on your judgment without realizing how much thought you put into it.',
  'Scorpio': 'Intense and private, you feel everything at full volume but reveal little. Trust, once earned, runs deep, and once someone crosses you, it\'s difficult to fully let it go. You\'re drawn to what\'s hidden beneath the surface, in people and in situations, and you rarely settle for the easy, obvious answer.',
  'Sagittarius': 'Restless and optimistic, you\'re chasing meaning, not comfort. Freedom isn\'t a want for you, it\'s a requirement, and feeling boxed in by routine or obligation can make you genuinely miserable. You\'re honest to a fault, sometimes too blunt for the room, but people respect that they always know where they stand with you.',
  'Capricorn': 'Disciplined and ambitious, you play the long game. Respect means more to you than applause, and you\'d rather be quietly effective than loudly praised. You take responsibility seriously, often more than your share of it, and you measure your worth by what you\'ve actually built rather than how it looks from the outside.',
  'Aquarius': 'Independent and idea-driven, you see the world a few steps ahead of everyone else. Belonging matters less to you than staying true to your own mind, even when that means standing apart from the group. You\'re drawn to causes bigger than yourself, and you\'d rather be right and alone than agreeable and wrong.',
  'Pisces': 'Dreamy and empathic, you absorb the emotional undercurrent of every room you\'re in. Imagination is where you actually live, and the line between what\'s real and what you feel is often blurrier for you than for other people. You give generously of your time and emotional energy, sometimes at your own expense.',
};

const _moonSignText = {
  'Aries': 'Emotionally, you react fast and move on fast. You\'d rather confront a feeling head-on than sit with it, and bottling things up isn\'t really in your nature. Your moods show up immediately and visibly, there\'s rarely a question of what you\'re feeling in the moment. Once it passes, though, it genuinely passes, you don\'t tend to hold grudges the way some signs do.',
  'Taurus': 'You need emotional stability like you need air. Comfort, routine, and physical safety calm your nervous system, and sudden change can leave you feeling unmoored even when nothing is actually wrong. You process feelings slowly and privately, and you\'re not easily talked out of how you feel once you\'ve settled into it.',
  'Gemini': 'You process feelings by talking them out. Silence with unresolved emotion is almost unbearable for you, and you\'ll often think out loud just to understand what you\'re actually feeling. Your moods shift quickly, and you can go from upset to curious to fine again faster than the people around you can keep up.',
  'Cancer': 'Your moods run deep and tidal. You feel safest when you\'re nurturing someone or being nurtured in return, and you notice emotional undercurrents in a room before anyone says a word. Old memories and attachments stay close to the surface for you, and the past has a way of resurfacing in how you feel about the present.',
  'Leo': 'You need to feel emotionally seen and appreciated. Being overlooked cuts deeper than you let on, even if you cover it with confidence. When you feel loved and valued, you\'re warm and generous in return, but withdrawal of attention can sting more than you\'d ever admit out loud.',
  'Virgo': 'You manage emotions by organizing them, naming the problem, fixing what\'s fixable. Anxiety shows up as over-preparation, a need to control the details so the bigger feeling stays manageable. You\'re hardest on yourself, often holding your own emotional reactions to a standard you\'d never expect from anyone else.',
  'Libra': 'You\'re emotionally attuned to others before yourself. Disharmony in a relationship can throw off your whole internal balance, and you\'ll often set aside your own feelings to keep the peace. You crave partnership and genuinely feel steadier when you\'re not navigating things alone.',
  'Scorpio': 'Your emotional world runs intense and private. You don\'t do surface-level feelings, everything goes deep or not at all, and you\'re naturally guarded about who gets to see the real depth of what you feel. Betrayal, even small, tends to leave a lasting mark, but so does genuine loyalty.',
  'Sagittarius': 'You process feelings by moving, physically, mentally, or geographically. Sitting still with sadness isn\'t your style, you\'d rather find the next thing to look forward to than dwell. You bounce back quickly, often finding humor or meaning in situations that would flatten other people for weeks.',
  'Capricorn': 'You keep your emotions controlled and rarely show vulnerability. Being needed often feels safer than needing someone, and asking for emotional support doesn\'t come naturally to you. You carry more quietly than people realize, and when you do let your guard down, it means something real.',
  'Aquarius': 'You experience emotions almost intellectually, analyzing feelings instead of just feeling them. Detachment is a defense mechanism, a way of staying objective when things get overwhelming. You care deeply about people in general, sometimes more easily than you connect with the person right in front of you.',
  'Pisces': 'Your emotions blend easily with others\' feelings, you can lose track of where theirs end and yours begin. You absorb moods from the people and environments around you, which makes you deeply empathetic but also easily drained. Alone time isn\'t optional for you, it\'s how you recover your own emotional center.',
};

Widget _privacyLink() {
  return GestureDetector(
    onTap: () => launchUrl(Uri.parse('https://www.delphicollective.org/sidereal-sky')),
    child: Text(
      'Privacy Policy',
      style: TextStyle(
        fontFamily: 'LibreBaskerville',
        fontSize: 12,
        color: Colors.white24,
        decoration: TextDecoration.underline,
        decorationColor: Colors.white24,
      ),
    ),
  );
}

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({super.key});

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> {
  bool _isUnlocked = false;
  BirthInfo? _birthInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final info = await BirthInfoService.load();
    final cache = await BirthInfoService.loadChart();

    bool unlocked = cache != null; // fast path: cached chart = already paid
    if (!unlocked) {
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        unlocked = customerInfo.entitlements.active.containsKey(_entitlementId);
      } catch (_) {}
    }

    setState(() {
      _birthInfo = info;
      _isUnlocked = unlocked;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isUnlocked && _birthInfo != null)
            GestureDetector(
              onTap: () => setState(() => _birthInfo = null),
              onLongPress: kDebugMode ? () async {
                await BirthInfoService.clear();
                setState(() { _isUnlocked = false; _birthInfo = null; });
              } : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Edit', style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white38)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: _gold))
                : !_isUnlocked
                    ? _LockedView(onUnlock: () async {
                        setState(() => _isUnlocked = true);
                      })
                    : _birthInfo == null
                        ? _BirthFormView(onSaved: (info) => setState(() => _birthInfo = info))
                        : _BirthChartResultView(birthInfo: _birthInfo!),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(child: _privacyLink()),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Locked ────────────────────────────────────────────────────────────────────

class _LockedView extends StatelessWidget {
  const _LockedView({required this.onUnlock});
  final Future<void> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Birth Chart', style: delphiLabelStyle),
          const SizedBox(height: 8),
          Container(height: 2, width: 220, color: const Color(0xFF4A148C)),
          const SizedBox(height: 28),
          Text(
            'Not your "sun sign." Your actual sidereal chart: every planet calculated from the real sky the moment you were born.',
            style: delphiBodyStyle.copyWith(fontSize: 15, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _purple.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _gold.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text('What you get', style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 14)),
                const SizedBox(height: 12),
                _bulletRow('☀️', 'Sun sign, sidereal not tropical'),
                _bulletRow('🌙', 'Moon sign + phase at birth'),
                _bulletRow('💫', 'Mercury, Venus, Mars'),
                _bulletRow('🪐', 'Jupiter, Saturn, Uranus, Neptune, Pluto'),
                _bulletRow('📐', 'All positions to the exact degree'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _glossaryCard('Sidereal', 'The zodiac system based on the actual current positions of the constellations in the sky, rather than the seasons.'),
_glossaryCard('Moon Phase at Birth', 'The moon\'s stage in its cycle the moment you were born. Shapes emotional rhythm and inner life.'),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 24, spreadRadius: 2)],
              ),
              child: Text(
                'Unlock  ·  \$0.99',
                style: delphiBodyStyle.copyWith(color: _background, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              try {
                final info = await Purchases.restorePurchases();
                if (info.entitlements.active.containsKey(_entitlementId)) {
                  await onUnlock();
                }
              } catch (_) {}
            },
            child: Text('Restore Purchase', style: delphiBodyStyle.copyWith(fontSize: 13, color: Colors.white38)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _bulletRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: delphiBodyStyle.copyWith(fontSize: 13, color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _glossaryCard(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _purple.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(term, style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 15)),
            const SizedBox(height: 6),
            Text(definition, style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────────────────────────

class _BirthFormView extends StatefulWidget {
  const _BirthFormView({required this.onSaved});
  final ValueChanged<BirthInfo> onSaved;

  @override
  State<_BirthFormView> createState() => _BirthFormViewState();
}

class _BirthFormViewState extends State<_BirthFormView> {
  DateTime? _date;
  TimeOfDay? _time;
  final _locationController = TextEditingController();
  bool _saving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _gold, surface: _purple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _gold, surface: _purple),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (_date == null || _time == null) return;
    setState(() => _saving = true);
    final dt = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );
    final info = BirthInfo(dateTime: dt, location: _locationController.text.trim());
    await BirthInfoService.save(info);
    await BirthInfoService.clearChart();
    widget.onSaved(info);
  }

  bool get _canSave => _date != null && _time != null && !_saving;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Birth Chart', style: delphiLabelStyle),
          const SizedBox(height: 8),
          Container(height: 2, width: 220, color: const Color(0xFF4A148C)),
          const SizedBox(height: 8),
          Text(
            'Enter your birth details to calculate your sidereal positions. Sidereal Sky does not store any of your information, it\'s stored only on your device.',
            style: delphiBodyStyle.copyWith(fontSize: 13, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          _formFieldWithInfo(
            label: 'Birth Date',
            value: _date != null ? DateFormat('MMMM d, y').format(_date!) : null,
            placeholder: 'Select date',
            onTap: _pickDate,
            info: 'We need your birth date to show you the position of the stars at the time you were born.',
          ),
          const SizedBox(height: 16),
          _formFieldWithInfo(
            label: 'Birth Time',
            value: _time?.format(context),
            placeholder: 'Select time',
            onTap: _pickTime,
            info: 'We need your birth time because the Moon moves fast. Knowing the exact time helps us calculate your Moon position and your rising sign accurately.',
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: _canSave ? _save : null,
            child: AnimatedOpacity(
              opacity: _canSave ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 24, spreadRadius: 2)],
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _background, strokeWidth: 2))
                    : Text('Calculate My Chart', style: delphiBodyStyle.copyWith(color: _background, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showInfo(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A0A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white70, height: 1.6)),
        ),
      ),
    );
  }

  Widget _formFieldWithInfo({
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    required String info,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 14)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showInfo(info),
              child: const Icon(Icons.info_outline, color: Colors.white24, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _purple.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: value != null ? _gold.withOpacity(0.4) : Colors.white12),
            ),
            child: Text(
              value ?? placeholder,
              style: delphiBodyStyle.copyWith(fontSize: 15, color: value != null ? Colors.white : Colors.white24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textFieldWithInfo({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required String info,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 14)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showInfo(info),
              child: const Icon(Icons.info_outline, color: Colors.white24, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: delphiBodyStyle.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white24),
            filled: true,
            fillColor: _purple.withOpacity(0.4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _gold.withOpacity(0.5))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Chart Result ──────────────────────────────────────────────────────────────

class _BirthChartResultView extends StatefulWidget {
  const _BirthChartResultView({required this.birthInfo});
  final BirthInfo birthInfo;

  @override
  State<_BirthChartResultView> createState() => _BirthChartResultViewState();
}

class _BirthChartResultViewState extends State<_BirthChartResultView> {
  bool _isLoading = true;
  String? _error;

  String _sunSign = '';
  String _sunSidereal = '';
  String _moonSign = '';
  String _moonSidereal = '';
  String _moonPhase = '';
  double _siderealMoonLon = 0;
  // Planets
  final Map<String, String> _planetSigns = {};
  final Map<String, String> _planetDegrees = {};

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  Future<void> _calculate() async {
    // Load from cache first — birth positions never change
    final cached = await BirthInfoService.loadChart();
    if (cached != null) {
      setState(() {
        _sunSign = cached.sunSign;
        _sunSidereal = cached.sunSidereal;
        _moonSign = cached.moonSign;
        _moonSidereal = cached.moonSidereal;
        _moonPhase = cached.moonPhase;
        _siderealMoonLon = cached.siderealMoonLon;
        _planetSigns.addAll(cached.planetSigns);
        _planetDegrees.addAll(cached.planetDegrees);
        // Ensure Sun/Moon always appear in grid even with older cache
        _planetSigns['Sun'] ??= cached.sunSign;
        _planetDegrees['Sun'] ??= cached.sunSidereal;
        _planetSigns['Moon'] ??= cached.moonSign;
        _planetDegrees['Moon'] ??= cached.moonSidereal;
        _isLoading = false;
      });
      return;
    }

    try {
      final dt = widget.birthInfo.dateTime;
      final start = dt.subtract(const Duration(minutes: 1));
      final end = dt.add(const Duration(minutes: 1));

      String fmt(DateTime d) => d.toIso8601String().split('.').first + 'Z';
      // Fetch Sun and Moon in parallel — show the chart immediately after
      final coreResults = await Future.wait([
        AstroService.fetchAstroData(startDate: fmt(start), endDate: fmt(end), stepSize: '1m', command: '10'),
        AstroService.fetchAstroData(startDate: fmt(start), endDate: fmt(end), stepSize: '1m', command: '301'),
      ]);

      final sunData = AstroService.parseAstroData(coreResults[0]);
      final moonData = AstroService.parseAstroData(coreResults[1]);

      if (sunData.isEmpty || moonData.isEmpty) throw Exception('No data returned');

      final sunLon = sunData[0].longitude;
      final moonLon = moonData[0].longitude;
      final ayanamsa = calculateLahiriAyanamsa(dt);
      final siderealSun = adjustToSidereal(sunLon, ayanamsa);
      final siderealMoon = adjustToSidereal(moonLon, ayanamsa);
      final elongation = (moonLon - sunLon + 360) % 360;

      // Show Sun + Moon immediately, stream planets in one by one
      setState(() {
        _sunSign = getAstrologySign(siderealSun);
        _sunSidereal = '${siderealSun.toStringAsFixed(4)}°';
        _moonSign = getAstrologySign(siderealMoon);
        _moonSidereal = '${siderealMoon.toStringAsFixed(4)}°';
        _moonPhase = AstroService.calculateMoonPhase(elongation);
        _siderealMoonLon = siderealMoon;
        _planetSigns['Sun'] = getAstrologySign(siderealSun);
        _planetDegrees['Sun'] = '${siderealSun.toStringAsFixed(2)}°';
        _planetSigns['Moon'] = getAstrologySign(siderealMoon);
        _planetDegrees['Moon'] = '${siderealMoon.toStringAsFixed(2)}°';
        _isLoading = false;
      });

      const planetCommands = {
        'Mercury': '199',
        'Venus': '299',
        'Mars': '499',
        'Jupiter': '599',
        'Saturn': '699',
        'Uranus': '799',
        'Neptune': '899',
        'Pluto': '999',
      };

      final signs = <String, String>{};
      final degrees = <String, String>{};
      for (final entry in planetCommands.entries) {
        final raw = await AstroService.fetchAstroData(startDate: fmt(start), endDate: fmt(end), stepSize: '1m', command: entry.value);
        final data = AstroService.parseAstroData(raw);
        if (data.isNotEmpty) {
          final sidereal = adjustToSidereal(data[0].longitude, ayanamsa);
          signs[entry.key] = getAstrologySign(sidereal);
          degrees[entry.key] = '${sidereal.toStringAsFixed(2)}°';
          if (mounted) setState(() {
            _planetSigns[entry.key] = signs[entry.key]!;
            _planetDegrees[entry.key] = degrees[entry.key]!;
          });
        }
      }

      // Save complete chart to cache once all planets are loaded
      if (signs.length == planetCommands.length) {
        await BirthInfoService.saveChart(ChartCache(
          sunSign: _sunSign,
          sunSidereal: _sunSidereal,
          moonSign: _moonSign,
          moonSidereal: _moonSidereal,
          moonPhase: _moonPhase,
          siderealMoonLon: _siderealMoonLon,
          planetSigns: signs,
          planetDegrees: degrees,
        ));
      }
    } catch (e) {
      setState(() {
        _error = 'Could not calculate chart. Check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  String _getSeason(DateTime dt) {
    final m = dt.month;
    final d = dt.day;
    final md = m * 100 + d;
    if (md >= 320 && md <= 620) return 'Spring';
    if (md >= 621 && md <= 922) return 'Summer';
    if (md >= 923 && md <= 1220) return 'Fall';
    return 'Winter';
  }

  String _signImagePath(String sign) {
    const base = 'assets/images/Astrology Signs/';
    const signs = {
      'Aries': 'Aries.png', 'Taurus': 'Taurus.png', 'Gemini': 'Gemini.png',
      'Cancer': 'Cancer.png', 'Leo': 'Leo.png', 'Virgo': 'Virgo.png',
      'Libra': 'Libra.png', 'Scorpio': 'Scorpio.png', 'Sagittarius': 'Sagittarius.png',
      'Capricorn': 'Capricorn.png', 'Aquarius': 'Aquarius.png', 'Pisces': 'Pisces.png',
    };
    return base + (signs[sign] ?? 'Aries.png');
  }

  Widget _signCircle(String label, String sign) {
    return Column(
      children: [
        Text(label, style: delphiUtilityStyle.copyWith(color: Colors.white.withOpacity(0.8))),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(color: Color(0xFF080010), shape: BoxShape.circle),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(_signImagePath(sign), color: _gold, colorBlendMode: BlendMode.srcIn),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: _gold),
            const SizedBox(height: 20),
            Text('Calculating your chart...', style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white54)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: delphiBodyStyle.copyWith(fontSize: 14, color: Colors.white54), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => setState(() { _error = null; _isLoading = true; _calculate(); }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _gold.withOpacity(0.4)),
                  ),
                  child: Text('Try Again', style: delphiBodyStyle.copyWith(color: _gold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final birthDt = widget.birthInfo.dateTime;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 56),
      child: Column(
        children: [
          Text('Your Birth Chart', style: delphiLabelStyle.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Container(height: 2, width: 180, color: const Color(0xFF4A148C)),
          const SizedBox(height: 6),
          Text(DateFormat('MMMM d, y').format(birthDt), style: delphiHeaderStyle.copyWith(fontSize: 13, color: Colors.white60)),
          const SizedBox(height: 12),
          // Moon / Sun visual row — identical structure so they align
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF080010),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: _gold.withOpacity(0.55), blurRadius: 18, spreadRadius: 3)]),
                          child: MoonPhaseWidget(moonPhase: _moonPhase),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('$_moonPhase Moon\nin $_moonSign', style: delphiBodyStyle.copyWith(fontSize: 13, height: 1.5), textAlign: TextAlign.center),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF080010),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: _gold.withOpacity(0.55), blurRadius: 18, spreadRadius: 3)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              _signImagePath(_sunSign.isEmpty ? 'Aries' : _sunSign),
                              color: _gold, colorBlendMode: BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${_getSeason(birthDt)} Sun\nin $_sunSign', style: delphiBodyStyle.copyWith(fontSize: 13, height: 1.5), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Planets — two-column grid
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(color: _purple.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Planets', style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 14)),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  // Sun and Moon always first, sourced directly from state
                  final allEntries = [
                    if (_sunSign.isNotEmpty) MapEntry('Sun', _sunSign),
                    if (_moonSign.isNotEmpty) MapEntry('Moon', _moonSign),
                    ..._planetSigns.entries.where((e) => e.key != 'Sun' && e.key != 'Moon'),
                  ];
                  final entries = allEntries;
                  final left = entries.take((entries.length / 2).ceil()).toList();
                  final right = entries.skip((entries.length / 2).ceil()).toList();
                  Widget planetRow(MapEntry<String, String> e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_planetSymbols[e.key] ?? ''} ${e.key}',
                          style: delphiBodyStyle.copyWith(fontSize: 12, color: Colors.white70),
                        ),
                        Row(children: [
                          Text(e.key == 'Sun' ? _sunSidereal : e.key == 'Moon' ? _moonSidereal : (_planetDegrees[e.key] ?? ''), style: delphiBodyStyle.copyWith(fontSize: 11, color: Colors.white38)),
                          const SizedBox(width: 4),
                          Text(
                            '${_signSymbols[e.value] ?? ''} ${e.value}',
                            style: delphiBodyStyle.copyWith(fontSize: 11, color: _gold),
                          ),
                        ]),
                      ],
                    ),
                  );
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: left.map(planetRow).toList())),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: right.map(planetRow).toList())),
                    ],
                  );
                }),
              ],
            ),
          ),
          if (_sunSign.isNotEmpty || _moonSign.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _purple.withOpacity(0.35), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Sky Signature', style: delphiBodyItalicStyle.copyWith(color: _gold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text(
                    [
                      if (_sunSignText[_sunSign] != null) _sunSignText[_sunSign]!,
                      if (_moonSignText[_moonSign] != null) _moonSignText[_moonSign]!,
                    ].join(' '),
                    style: delphiBodyItalicStyle.copyWith(fontSize: 13, color: Colors.white70, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
