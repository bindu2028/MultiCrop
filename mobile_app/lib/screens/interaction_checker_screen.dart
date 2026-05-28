import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/herb_library_data.dart';
import '../data/interaction_checker_data.dart';

class InteractionCheckerScreen extends StatefulWidget {
  const InteractionCheckerScreen({super.key});

  @override
  State<InteractionCheckerScreen> createState() => _InteractionCheckerScreenState();
}

class _InteractionCheckerScreenState extends State<InteractionCheckerScreen> {
  String? _selectedHerb;
  String? _selectedMed;
  InteractionItem? _interaction;
  bool _checked = false;

  final List<String> _herbsList = kHerbLibraryData.map((h) => h.name).toList();

  void _checkInteraction() {
    if (_selectedHerb == null || _selectedMed == null) return;
    
    HapticFeedback.selectionClick();
    final match = InteractionLookup.find(_selectedHerb!, _selectedMed!);
    
    setState(() {
      _interaction = match;
      _checked = true;
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedHerb = null;
      _selectedMed = null;
      _interaction = null;
      _checked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4F8),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // ⚠️ HEADER TITLE CARD
          Card(
            color: const Color(0xFFECEFF1),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFCFD8DC)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF37474F),
                    child: Icon(Icons.shield_outlined, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Virtual Clinician Checker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF263238),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Analyze safety profiles and potential interactions between natural herbs and standard drugs.',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 1. SELECT HERB DROPDOWN
          const Text(
            'Select Natural Herb',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1E3F8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedHerb,
                hint: const Text('Choose a medicinal plant...'),
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                items: _herbsList.map((herb) {
                  return DropdownMenuItem(
                    value: herb,
                    child: Text(herb),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedHerb = val;
                    _checked = false;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. SELECT SYNTHETIC MEDICATION DROPDOWN
          const Text(
            'Select Modern Medication',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1E3F8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMed,
                hint: const Text('Choose synthetic prescription drug...'),
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                items: kSyntheticMedications.map((med) {
                  return DropdownMenuItem(
                    value: med,
                    child: Text(med),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMed = val;
                    _checked = false;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. ACTION BUTTONS
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.analytics_rounded),
                  label: const Text('Analyze Safety', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _selectedHerb == null || _selectedMed == null
                      ? null
                      : _checkInteraction,
                ),
              ),
              if (_checked) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC62828),
                      side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _reset,
                    child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 4. DYNAMIC SAFETY ANALYSIS CARD RESULT
          if (_checked) _buildResultCard(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    // If no interaction exists, show the Safe / Friendly card
    if (_interaction == null) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Mapped Interactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Safe under dietary consumption',
                        style: TextStyle(color: Color(0xFF0D47A1), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'There are no standard clinical warnings recorded between $_selectedHerb and $_selectedMed in our current natural pharmacology database.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1976D2)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF0D47A1), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dietary culinary consumption is safe. However, always exercise caution with high-dosage extracts.',
                      style: TextStyle(color: Color(0xFF0D47A1), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final data = _interaction!;
    
    // Choose theme colors based on severity
    Color mainColor;
    Color lightColor;
    Color darkColor;
    IconData icon;

    switch (data.severity) {
      case InteractionSeverity.highRisk:
        mainColor = const Color(0xFFEF5350); // Bright Red
        lightColor = const Color(0xFFFFEBEE);
        darkColor = const Color(0xFFC62828);
        icon = Icons.gpp_bad_rounded;
        break;
      case InteractionSeverity.caution:
        mainColor = const Color(0xFFFFB74D); // Amber
        lightColor = const Color(0xFFFFF8E1);
        darkColor = const Color(0xFFE65100);
        icon = Icons.warning_amber_rounded;
        break;
      case InteractionSeverity.synergistic:
        mainColor = const Color(0xFF42A5F5); // Blue
        lightColor = const Color(0xFFE3F2FD);
        darkColor = const Color(0xFF1565C0);
        icon = Icons.volunteer_activism_rounded;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mainColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.severity == InteractionSeverity.highRisk
                          ? 'CRITICAL WARNING ALERT'
                          : data.severity == InteractionSeverity.caution
                              ? 'EXERCISE CAUTION'
                              : 'NATURAL SYNERGY DETECTED',
                      style: TextStyle(color: darkColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: TextStyle(fontSize: 13.5, height: 1.45, color: darkColor.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mainColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: darkColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'SAFETY & DOSAGE ADVICE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: darkColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data.safetyAdvice,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Color(0xFF444444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
