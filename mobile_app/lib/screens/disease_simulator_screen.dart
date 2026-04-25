import 'package:flutter/material.dart';

class DiseaseSimulatorScreen extends StatefulWidget {
  final String diseaseName;

  const DiseaseSimulatorScreen({super.key, required this.diseaseName});

  @override
  State<DiseaseSimulatorScreen> createState() => _DiseaseSimulatorScreenState();
}

class _DiseaseSimulatorScreenState extends State<DiseaseSimulatorScreen> {
  double _day = 1.0;

  @override
  Widget build(BuildContext context) {
    // Math to calculate image opacities based on days
    // Day 1 to 7: Crossfade Early -> Mid
    // Day 7 to 14: Crossfade Mid -> Severe
    
    double earlyOpacity = 0.0;
    double midOpacity = 0.0;
    double severeOpacity = 0.0;

    if (_day <= 7.0) {
      // 1 to 7
      double progress = (_day - 1.0) / 6.0; // 0.0 to 1.0
      earlyOpacity = 1.0 - progress;
      midOpacity = progress;
      severeOpacity = 0.0;
    } else {
      // 7 to 14
      double progress = (_day - 7.0) / 7.0; // 0.0 to 1.0
      earlyOpacity = 0.0;
      midOpacity = 1.0 - progress;
      severeOpacity = progress;
    }

    // Default to tomato late blight demo assets
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Progression Simulator', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: earlyOpacity,
                    child: Image.asset('assets/images/simulations/tomato_late_blight/early.png', fit: BoxFit.cover),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: midOpacity,
                    child: Image.asset('assets/images/simulations/tomato_late_blight/mid.png', fit: BoxFit.cover),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: severeOpacity,
                    child: Image.asset('assets/images/simulations/tomato_late_blight/severe.png', fit: BoxFit.cover),
                  ),
                ),
                // Overlay text
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Day ${_day.toInt()}',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF1B2F20),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Text(
                  'Untreated ${widget.diseaseName}',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drag the slider to see how the disease will ravage the leaf if left untreated over two weeks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: Colors.redAccent.withValues(alpha: 0.3),
                    trackHeight: 8,
                  ),
                  child: Slider(
                    value: _day,
                    min: 1.0,
                    max: 14.0,
                    onChanged: (val) {
                      setState(() {
                        _day = val;
                      });
                    },
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Day 1', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
                    Text('Day 7', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
                    Text('Day 14', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
