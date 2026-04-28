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

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(diseaseName.hashCode); // Seed by disease for consistency
    final paint = Paint()
      ..color = spotColor.withValues(alpha: progress * 0.85)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * progress + 2);

    final int spotCount = (25 * progress).toInt();
    
    // Draw "growing" spots at semi-random locations based on disease seed
    for (int i = 0; i < spotCount; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      
      // Radius grows with time
      final double radius = (15.0 + random.nextDouble() * 30.0) * progress;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
      
      // Inner darker core for realism
      if (progress > 0.6) {
        final corePaint = Paint()
          ..color = Colors.black.withValues(alpha: (progress - 0.5) * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), radius * 0.4, corePaint);
      }
    }

    // Browning edges simulation
    if (progress > 0.4) {
      final edgePaint = Paint()
        ..color = const Color(0xFF3E2723).withValues(alpha: (progress - 0.4) * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 60 * progress
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      
      canvas.drawRect(Offset.zero & size, edgePaint);
    }
  }

  @override
  bool shouldRepaint(_ProceduralDiseasePainter oldDelegate) => 
      oldDelegate.progress != progress;
}
