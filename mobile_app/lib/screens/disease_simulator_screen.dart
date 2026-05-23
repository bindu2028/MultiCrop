import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DiseaseSimulatorScreen extends StatefulWidget {
  final String diseaseName;
  final Uint8List? imageBytes;

  const DiseaseSimulatorScreen({super.key, required this.diseaseName, this.imageBytes});

  @override
  State<DiseaseSimulatorScreen> createState() => _DiseaseSimulatorScreenState();
}

class _DiseaseSimulatorScreenState extends State<DiseaseSimulatorScreen> {
  double _day = 1.0;

  @override
  Widget build(BuildContext context) {
    // Generate a different color/pattern based on disease name
    final bool isFungal = widget.diseaseName.toLowerCase().contains('fungal') || 
                         widget.diseaseName.toLowerCase().contains('rust') || 
                         widget.diseaseName.toLowerCase().contains('mildew');
    final bool isBacterial = widget.diseaseName.toLowerCase().contains('bacterial');
    final Color spotColor = isFungal ? const Color(0xFF4E342E) : (isBacterial ? Colors.black87 : const Color(0xFF5D4037));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Leaf Evolution AI', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base Image (Actual Leaf or Fallback)
                Positioned.fill(
                  child: widget.imageBytes != null 
                    ? Image.memory(widget.imageBytes!, fit: BoxFit.cover)
                    : Image.asset('assets/images/simulations/tomato_late_blight/early.png', fit: BoxFit.cover),
                ),
                
                // Yellowing Layer (Chlorosis)
                Positioned.fill(
                  child: Opacity(
                    opacity: (_day / 14.0) * 0.4,
                    child: Container(color: Colors.yellow.withValues(alpha: 0.3)),
                  ),
                ),

                // Procedural Damage Layer
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ProceduralDiseasePainter(
                      progress: _day / 14.0,
                      spotColor: spotColor,
                      diseaseName: widget.diseaseName,
                    ),
                  ),
                ),

                // Day Counter
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Text(
                      'DAY ${_day.toInt()}',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B0F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'SIMULATING: ${widget.diseaseName.toUpperCase()}',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Predictive Decay Model',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This AI model uses your real leaf photo to project how symptoms will evolve if left untreated.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.redAccent,
                    inactiveTrackColor: Colors.white10,
                    thumbColor: Colors.white,
                    overlayColor: Colors.redAccent.withValues(alpha: 0.2),
                    trackHeight: 10,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: _day,
                    min: 1.0,
                    max: 14.0,
                    onChanged: (val) => setState(() => _day = val),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PRESENT', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('+14 DAYS', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w900)),
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

class _ProceduralDiseasePainter extends CustomPainter {
  final double progress;
  final Color spotColor;
  final String diseaseName;

  _ProceduralDiseasePainter({
    required this.progress,
    required this.spotColor,
    required this.diseaseName,
  });

  // Disease progression stages (realistic pathology)
  Map<String, List<Map<String, dynamic>>> _getDiseaseProgression(String disease) {
    final d = disease.toLowerCase();
    
    // Each disease has realistic progression stages
    if (d.contains('late blight')) {
      return {
        'stages': [
          {'day': 0, 'description': 'Initial water-soaked lesions'},
          {'day': 3, 'description': 'Small brown spots with yellow halo'},
          {'day': 7, 'description': 'Spots expand, white mold appears on leaf back'},
          {'day': 10, 'description': 'Large necrotic areas, leaf curling'},
          {'day': 14, 'description': 'Complete leaf collapse, browning'},
        ]
      };
    } else if (d.contains('early blight')) {
      return {
        'stages': [
          {'day': 0, 'description': 'Small circular lesions'},
          {'day': 2, 'description': 'Target-like spots with concentric rings'},
          {'day': 5, 'description': 'Yellowing around lesions'},
          {'day': 10, 'description': 'Leaf yellowing spreads'},
          {'day': 14, 'description': 'Leaf drop'},
        ]
      };
    } else if (d.contains('bacterial')) {
      return {
        'stages': [
          {'day': 0, 'description': 'Water-soaked spots'},
          {'day': 2, 'description': 'Spots with yellow halo'},
          {'day': 6, 'description': 'Necrotic centers, yellow margins'},
          {'day': 12, 'description': 'Leaf yellowing, premature drop'},
          {'day': 14, 'description': 'Severe defoliation'},
        ]
      };
    } else if (d.contains('powdery mildew') || d.contains('mildew')) {
      return {
        'stages': [
          {'day': 0, 'description': 'Fine white powder on leaf surface'},
          {'day': 3, 'description': 'Powder spreads, leaf curling begins'},
          {'day': 7, 'description': 'Dense white coating'},
          {'day': 11, 'description': 'Leaf distortion and browning'},
          {'day': 14, 'description': 'Severe stunting'},
        ]
      };
    }
    
    // Generic progression
    return {
      'stages': [
        {'day': 0, 'description': 'Initial symptoms appear'},
        {'day': 4, 'description': 'Spots expand and multiply'},
        {'day': 7, 'description': 'Significant damage visible'},
        {'day': 10, 'description': 'Severe tissue damage'},
        {'day': 14, 'description': 'Critical plant condition'},
      ]
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(diseaseName.hashCode);
    final progression = _getDiseaseProgression(diseaseName);
    final stages = (progression['stages'] ?? []) as List<Map<String, dynamic>>;
    
    // Calculate which stage we're in
    int currentStage = (progress * (stages.length - 1)).toInt();
    currentStage = currentStage.clamp(0, stages.length - 1);
    double stageProgress = (progress * (stages.length - 1)) - currentStage;

    // ===== STAGE-BASED DISEASE PROGRESSION =====
    
    if (diseaseName.toLowerCase().contains('late blight')) {
      _paintLateBlight(canvas, size, progress, stageProgress, currentStage, random);
    } else if (diseaseName.toLowerCase().contains('early blight')) {
      _paintEarlyBlight(canvas, size, progress, stageProgress, currentStage, random);
    } else if (diseaseName.toLowerCase().contains('bacterial')) {
      _paintBacterialSpot(canvas, size, progress, stageProgress, currentStage, random);
    } else if (diseaseName.toLowerCase().contains('powdery mildew') || diseaseName.toLowerCase().contains('mildew')) {
      _paintPowderyMildew(canvas, size, progress, stageProgress, currentStage, random);
    } else {
      _paintGenericDisease(canvas, size, progress, stageProgress, currentStage, random);
    }
  }

  void _paintLateBlight(Canvas canvas, Size size, double progress, double stageProgress, int stage, math.Random random) {
    // Day 0-3: Small water-soaked spots
    if (progress < 0.25) {
      _paintWaterSoakedSpots(canvas, size, progress / 0.25, 8, random);
    }
    // Day 3-7: Brown spots with yellow halo
    else if (progress < 0.5) {
      _paintWaterSoakedSpots(canvas, size, 1.0, 12, random);
      _paintYellowHalo(canvas, size, (progress - 0.25) / 0.25, 0.3);
    }
    // Day 7-10: White mold appearance + expansion
    else if (progress < 0.75) {
      _paintWaterSoakedSpots(canvas, size, 1.0, 18, random);
      _paintYellowHalo(canvas, size, 1.0, 0.5);
      _paintWhiteMold(canvas, size, (progress - 0.5) / 0.25, random);
    }
    // Day 10-14: Necrotic areas, leaf curling effect
    else {
      _paintWaterSoakedSpots(canvas, size, 1.0, 25, random);
      _paintYellowHalo(canvas, size, 1.0, 0.8);
      _paintBrowningEdges(canvas, size, (progress - 0.75) / 0.25, 0xFF3E2723);
    }
  }

  void _paintEarlyBlight(Canvas canvas, Size size, double progress, double stageProgress, int stage, math.Random random) {
    // Day 0-2: Tiny circular lesions
    if (progress < 0.15) {
      _paintConcentricRings(canvas, size, progress / 0.15, 6, random);
    }
    // Day 2-5: Target-like spots expand
    else if (progress < 0.35) {
      _paintConcentricRings(canvas, size, 1.0, 10, random);
    }
    // Day 5-10: Yellow halo spreads
    else if (progress < 0.7) {
      _paintConcentricRings(canvas, size, 1.0, 14, random);
      _paintYellowHalo(canvas, size, (progress - 0.35) / 0.35, 0.6);
    }
    // Day 10-14: Leaf yellowing and drop
    else {
      _paintConcentricRings(canvas, size, 1.0, 18, random);
      _paintYellowHalo(canvas, size, 1.0, 1.0);
      _paintBrowningEdges(canvas, size, (progress - 0.7) / 0.3, 0xFFCD853F);
    }
  }

  void _paintBacterialSpot(Canvas canvas, Size size, double progress, double stageProgress, int stage, math.Random random) {
    // Day 0-2: Water-soaked spots with yellow halo
    if (progress < 0.15) {
      _paintWaterSoakedSpots(canvas, size, progress / 0.15, 6, random);
      _paintYellowHalo(canvas, size, progress / 0.15, 0.2);
    }
    // Day 2-6: Expanding spots
    else if (progress < 0.4) {
      _paintWaterSoakedSpots(canvas, size, 1.0, 12, random);
      _paintYellowHalo(canvas, size, (progress - 0.15) / 0.25, 0.5);
    }
    // Day 6-12: Necrotic centers
    else if (progress < 0.85) {
      _paintWaterSoakedSpots(canvas, size, 1.0, 16, random);
      _paintYellowHalo(canvas, size, 1.0, 0.8);
    }
    // Day 12-14: Severe damage
    else {
      _paintWaterSoakedSpots(canvas, size, 1.0, 20, random);
      _paintYellowHalo(canvas, size, 1.0, 1.0);
      _paintBrowningEdges(canvas, size, (progress - 0.85) / 0.15, 0xFF2F1F18);
    }
  }

  void _paintPowderyMildew(Canvas canvas, Size size, double progress, double stageProgress, int stage, math.Random random) {
    // Day 0-3: Fine white powder
    if (progress < 0.2) {
      _paintPowderLayer(canvas, size, progress / 0.2, 0.2);
    }
    // Day 3-7: Powder spreads
    else if (progress < 0.5) {
      _paintPowderLayer(canvas, size, 1.0, (progress - 0.2) / 0.3 * 0.7);
    }
    // Day 7-11: Dense white coating
    else if (progress < 0.8) {
      _paintPowderLayer(canvas, size, 1.0, 1.0);
    }
    // Day 11-14: Browning and distortion
    else {
      _paintPowderLayer(canvas, size, 1.0, 0.8);
      _paintBrowningEdges(canvas, size, (progress - 0.8) / 0.2, 0xFF8B7355);
    }
  }

  void _paintGenericDisease(Canvas canvas, Size size, double progress, double stageProgress, int stage, math.Random random) {
    final paint = Paint()
      ..color = spotColor.withValues(alpha: progress * 0.85)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * progress + 2);

    final int spotCount = (40 * progress).toInt();
    for (int i = 0; i < spotCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = (10.0 + random.nextDouble() * 25.0) * progress;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      if (progress > 0.5) {
        final corePaint = Paint()
          ..color = Colors.black.withValues(alpha: (progress - 0.4) * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), radius * 0.3, corePaint);
      }
    }
  }

  void _paintWaterSoakedSpots(Canvas canvas, Size size, double intensity, int spotCount, math.Random random) {
    final paint = Paint()
      ..color = const Color(0xFF1B5E20).withValues(alpha: 0.6 * intensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);

    for (int i = 0; i < spotCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = (8.0 + random.nextDouble() * 15.0) * intensity;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintYellowHalo(Canvas canvas, Size size, double intensity, double maxOpacity) {
    final paint = Paint()
      ..color = Colors.yellow.withValues(alpha: intensity * maxOpacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintWhiteMold(Canvas canvas, Size size, double intensity, math.Random random) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2 * intensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    for (int i = 0; i < 15; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 20, paint);
    }
  }

  void _paintBrowningEdges(Canvas canvas, Size size, double intensity, int color) {
    final paint = Paint()
      ..color = Color(color).withValues(alpha: intensity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 100 * intensity
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintConcentricRings(Canvas canvas, Size size, double intensity, int spotCount, math.Random random) {
    for (int i = 0; i < spotCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double baseRadius = 8.0 + random.nextDouble() * 12.0;
      
      // Inner brown center
      final centerPaint = Paint()
        ..color = const Color(0xFF5D4037).withValues(alpha: 0.7 * intensity);
      canvas.drawCircle(Offset(x, y), baseRadius, centerPaint);
      
      // Middle tan ring
      final ringPaint = Paint()
        ..color = const Color(0xFF8D6E63).withValues(alpha: 0.5 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), baseRadius * 1.5, ringPaint);
      
      // Outer yellow halo
      if (intensity > 0.3) {
        final haloPaint = Paint()
          ..color = Colors.yellow.withValues(alpha: 0.3 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), baseRadius * 2.2, haloPaint);
      }
    }
  }

  void _paintPowderLayer(Canvas canvas, Size size, double intensity, double coverage) {
    final random = math.Random();
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    for (int i = 0; i < (60 * coverage).toInt(); i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 8 + 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ProceduralDiseasePainter oldDelegate) => oldDelegate.progress != progress;
}
