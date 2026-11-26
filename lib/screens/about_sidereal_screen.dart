import 'package:flutter/material.dart';
import '../theme/delphi_text_styles.dart';
import '../widgets/sidereal_explainer.dart';

class AboutSiderealScreen extends StatelessWidget {
  const AboutSiderealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a0a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 18),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('What is sidereal?', style: delphiLabelStyle, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Center(child: Container(height: 2, width: 220, color: const Color(0xFF4A148C))),
              const SizedBox(height: 28),
              const SiderealExplainer(),
            ],
          ),
        ),
      ),
    );
  }
}
