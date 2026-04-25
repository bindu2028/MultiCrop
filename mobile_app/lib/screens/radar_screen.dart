import 'dart:math';
import 'package:flutter/material.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final List<_Alert> _alerts = [
    _Alert(disease: 'Late Blight', crop: 'Tomato', distance: '1.2 km', time: '10 mins ago', severity: 'High'),
    _Alert(disease: 'Powdery Mildew', crop: 'Apple', distance: '3.4 km', time: '1 hour ago', severity: 'Medium'),
    _Alert(disease: 'Leaf Spot', crop: 'Strawberry', distance: '5.1 km', time: '3 hours ago', severity: 'Low'),
    _Alert(disease: 'Rust', crop: 'Corn', distance: '8.0 km', time: 'Yesterday', severity: 'High'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      appBar: AppBar(
        title: const Text('Outbreak Radar', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1B2F20),
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radar rings
                ...List.generate(4, (index) {
                  return Container(
                    width: (index + 1) * 80.0,
                    height: (index + 1) * 80.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1),
                    ),
                  );
                }),
                // Sweep animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * pi,
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.transparent,
                              Colors.greenAccent.withValues(alpha: 0.1),
                              Colors.greenAccent.withValues(alpha: 0.6),
                            ],
                            stops: const [0.0, 0.85, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Blips
                const Positioned(top: 80, left: 120, child: _RadarBlip(color: Colors.red)),
                const Positioned(bottom: 60, right: 100, child: _RadarBlip(color: Colors.orange)),
                const Positioned(top: 150, right: 80, child: _RadarBlip(color: Colors.yellow)),
                
                // Center icon
                const Center(
                  child: Icon(Icons.location_on, color: Colors.greenAccent, size: 30),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Nearby Threats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                Text('Radius: 10km', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                Color dotColor;
                if (alert.severity == 'High') dotColor = Colors.red;
                else if (alert.severity == 'Medium') dotColor = Colors.orange;
                else dotColor = Colors.yellow;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    title: Text(alert.disease, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${alert.crop} • ${alert.distance} away\n${alert.time}'),
                    isThreeLine: true,
                    trailing: FilledButton.tonal(
                      onPressed: () {},
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE8F5E2), foregroundColor: const Color(0xFF2E7D32)),
                      child: const Text('View'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarBlip extends StatefulWidget {
  final Color color;
  const _RadarBlip({required this.color});

  @override
  State<_RadarBlip> createState() => _RadarBlipState();
}

class _RadarBlipState extends State<_RadarBlip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: widget.color, blurRadius: 6, spreadRadius: 2)
        ]),
      ),
    );
  }
}

class _Alert {
  final String disease;
  final String crop;
  final String distance;
  final String time;
  final String severity;

  _Alert({required this.disease, required this.crop, required this.distance, required this.time, required this.severity});
}
