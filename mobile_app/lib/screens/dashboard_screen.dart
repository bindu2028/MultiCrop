import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/scan_history_item.dart';
import '../services/history_service.dart';
import 'crop_calendar_screen.dart';
import 'plant_care_screen.dart';
import 'radar_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final ValueChanged<int> onNavigateToTab;
  final void Function([String? crop]) onScanRequested;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.onNavigateToTab,
    required this.onScanRequested,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final HistoryService _historyService = HistoryService();
  late Future<List<ScanHistoryItem>> _historyFuture;
  late final AnimationController _cardsAnimationController;
  bool _showAllCrops = false;

  final List<_PlantCardItem> _modelCrops = const [
    _PlantCardItem('Apple', [Color(0xFF78B256), Color(0xFF3D7135)], 'apple', 'assets/images/crops/apple.png'),
    _PlantCardItem('Bell Pepper', [Color(0xFF63B45E), Color(0xFF377F4A)], 'bell_pepper', 'assets/images/crops/bell_pepper.png'),
    _PlantCardItem('Cherry', [Color(0xFF80B96C), Color(0xFF4B7D3B)], 'cherry', 'assets/images/crops/cherry.png'),
    _PlantCardItem('Corn / Maize', [Color(0xFF85C161), Color(0xFF4D8D37)], 'corn_maize', 'assets/images/crops/corn_maize.png'),
    _PlantCardItem('Grape', [Color(0xFF6DAA75), Color(0xFF356947)], 'grape', 'assets/images/crops/grape.png'),
    _PlantCardItem('Peach', [Color(0xFF7EB65A), Color(0xFF4C7D37)], 'peach', 'assets/images/crops/peach.png'),
    _PlantCardItem('Potato', [Color(0xFF93B963), Color(0xFF5D8138)], 'potato', 'assets/images/crops/potato.png'),
    _PlantCardItem('Strawberry', [Color(0xFF71B864), Color(0xFF3C7E43)], 'strawberry', 'assets/images/crops/strawberry.png'),
    _PlantCardItem('Tomato', [Color(0xFF66B85C), Color(0xFF2E8040)], 'tomato', 'assets/images/crops/tomato.png'),
  ];

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.loadHistory();
    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _cardsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _historyService.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScanHistoryItem>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DashboardSkeleton();
        }

        final history = snapshot.data ?? const <ScanHistoryItem>[];
        final latest = history.isEmpty ? null : history.first;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ExploreHeader(
                  userName: widget.userName,
                  latestDisease: latest?.disease,
                ),
                const SizedBox(height: 18),
                _AnalyticsCard(history: history),
                const SizedBox(height: 18),
                _QuickToolsCard(
                  onCalendar: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const CropCalendarScreen()),
                  ),
                ),
                const SizedBox(height: 14),
                _PlantCareTipsCard(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const PlantCareScreen()),
                  ),
                ),

                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'Model Crops',
                  actionLabel: _showAllCrops ? 'Show Less' : 'Show More',
                  onActionTap: () => setState(() {
                    _showAllCrops = !_showAllCrops;
                  }),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _showAllCrops ? _modelCrops.length : 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.80,
                  ),
                  itemBuilder: (context, index) {
                    final item = _modelCrops[index];
                    final start = (index * 0.08).clamp(0.0, 0.75);
                    final end = (start + 0.25).clamp(0.0, 1.0);
                    final animation = CurvedAnimation(
                      parent: _cardsAnimationController,
                      curve: Interval(start, end, curve: Curves.easeOutCubic),
                    );

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final value = animation.value;
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _ModelCropCard(
                        item: item,
                        onTap: () => widget.onScanRequested(item.crop),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  final String userName;
  final String? latestDisease;

  const _ExploreHeader({
    required this.userName,
    required this.latestDisease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E2), Color(0xFFF4FBF1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E8D3)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Icon(Icons.eco_rounded, size: 140, color: const Color(0xFFD3E7CE).withValues(alpha: 0.5)),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF66B051),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.spa_outlined, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plant Disease Detection',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF37673B)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Wishing you a day full of green vibes!',
                        style: TextStyle(color: Color(0xFF5B6D5D), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latestDisease == null
                            ? 'Tap a crop card or the scan button to inspect a plant.'
                            : 'Latest result for $userName: $latestDisease',
                        style: const TextStyle(color: Color(0xFF748275), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD6A51B), size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ModelCropCard extends StatelessWidget {
  final _PlantCardItem item;
  final VoidCallback onTap;

  const _ModelCropCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: item.gradient,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: item.gradient,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, height: 1.05),
                    ),

                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.0),
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _QuickToolsCard extends StatelessWidget {
  final VoidCallback onCalendar;

  const _QuickToolsCard({required this.onCalendar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCalendar,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x264CAF50), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.calendar_month_rounded, size: 130, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crop Calendar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Season-wise sowing & harvesting tips',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutbreakRadarCard extends StatelessWidget {
  final VoidCallback onRadar;

  const _OutbreakRadarCard({required this.onRadar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRadar,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2F20),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
            ],
            image: const DecorationImage(
              image: NetworkImage('https://www.transparenttextures.com/patterns/stardust.png'), // Subtle texture
              opacity: 0.1,
              fit: BoxFit.cover,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.radar_rounded, color: Colors.greenAccent, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Outbreak Radar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.circle, color: Colors.redAccent, size: 8),
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Live community pathogen threats',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7FAF5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF66B051).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF4B8F45)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF6C786D))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFA0A7A0)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final List<ScanHistoryItem> history;
  const _AnalyticsCard({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }

    final total = history.length;
    final healthy = history.where((h) =>
        h.disease.toLowerCase().contains('healthy')).length;
    final diseased = total - healthy;
    final healthyPct = total > 0 ? (healthy / total * 100) : 0.0;
    final diseasedPct = total > 0 ? (diseased / total * 100) : 0.0;

    // Most common disease (excluding healthy)
    final diseaseCounts = <String, int>{};
    for (final item in history) {
      if (!item.disease.toLowerCase().contains('healthy')) {
        diseaseCounts[item.disease] = (diseaseCounts[item.disease] ?? 0) + 1;
      }
    }
    String topDisease = 'None detected';
    if (diseaseCounts.isNotEmpty) {
      topDisease = diseaseCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    // Most scanned crop
    final cropCounts = <String, int>{};
    for (final item in history) {
      final crop = item.crop.isNotEmpty ? item.crop : 'unknown';
      cropCounts[crop] = (cropCounts[crop] ?? 0) + 1;
    }
    String topCrop = 'N/A';
    if (cropCounts.isNotEmpty) {
      topCrop = cropCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      // Capitalize
      topCrop = topCrop.replaceAll('_', ' ');
      if (topCrop.isNotEmpty) {
        topCrop = topCrop[0].toUpperCase() + topCrop.substring(1);
      }
    }

    // Weekly sparkline (last 7 days)
    final now = DateTime.now();
    final weekCounts = List.filled(7, 0);
    for (final item in history) {
      final diff = now.difference(item.scannedAt).inDays;
      if (diff >= 0 && diff < 7) {
        weekCounts[6 - diff] += 1;
      }
    }
    final maxWeek = weekCounts.reduce(max);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E8DD)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: Color(0xFF7C4DFF), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Scan Analytics',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$total scans',
                  style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Pie chart + stats
          Row(
            children: [
              // Pie chart
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _PieChartPainter(
                    healthyPct: healthyPct,
                    diseasedPct: diseasedPct,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${healthyPct.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Color(0xFF2E7D32)),
                        ),
                        const Text(
                          'healthy',
                          style: TextStyle(
                              fontSize: 10, color: Color(0xFF6C786D)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),

              // Stats column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      icon: Icons.eco_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      label: 'Healthy',
                      value: '$healthy scans',
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      icon: Icons.coronavirus_rounded,
                      iconColor: const Color(0xFFEF5350),
                      label: 'Diseased',
                      value: '$diseased scans',
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      icon: Icons.bug_report_rounded,
                      iconColor: const Color(0xFFFF9800),
                      label: 'Top disease',
                      value: topDisease,
                    ),
                    const SizedBox(height: 8),
                    _StatRow(
                      icon: Icons.spa_rounded,
                      iconColor: const Color(0xFF42A5F5),
                      label: 'Top crop',
                      value: topCrop,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Weekly sparkline
          const Text(
            'Last 7 days',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6C786D)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = maxWeek > 0 ? (weekCounts[i] / maxWeek * 30) : 2.0;
                final label = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final dayIndex = (now.subtract(Duration(days: 6 - i)).weekday - 1) % 7;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          height: h.clamp(3.0, 30.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: weekCounts[i] > 0
                                  ? [const Color(0xFF66BB6A), const Color(0xFF81C784)]
                                  : [const Color(0xFFE0E0E0), const Color(0xFFEEEEEE)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label[dayIndex],
                          style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0E8DD)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.analytics_rounded,
                color: Color(0xFF7C4DFF), size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan Analytics',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1B5E20))),
                SizedBox(height: 3),
                Text('Scan your first plant to see stats here!',
                    style: TextStyle(color: Color(0xFF6C786D), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 12, color: Color(0xFF6C786D), fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF1B5E20), fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double healthyPct;
  final double diseasedPct;

  _PieChartPainter({required this.healthyPct, required this.diseasedPct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 10.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (healthyPct == 0 && diseasedPct == 0) return;

    final total = healthyPct + diseasedPct;
    final healthySweep = (healthyPct / total) * 2 * pi;
    final diseasedSweep = (diseasedPct / total) * 2 * pi;

    // Diseased arc (red/orange)
    final diseasedPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF5350), Color(0xFFFF7043)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, diseasedSweep, false, diseasedPaint);

    // Healthy arc (green)
    final healthyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        rect, -pi / 2 + diseasedSweep, healthySweep, false, healthyPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.healthyPct != healthyPct ||
      oldDelegate.diseasedPct != diseasedPct;
}

class _PlantCareTipsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PlantCareTipsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x2666BB6A),
                  blurRadius: 16,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.local_florist_rounded,
                    size: 130,
                    color: Colors.white.withValues(alpha: 0.08)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.local_florist_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plant Care Tips',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Expert care guides for all your crops',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _SkeletonBlock(height: 130, radius: 24),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _SkeletonBlock(height: 22, radius: 8)),
              SizedBox(width: 80),
            ],
          ),
          SizedBox(height: 10),
          _SkeletonGrid(),
          SizedBox(height: 18),
          _SkeletonBlock(height: 184, radius: 20),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (_, __) => const _SkeletonBlock(height: 140, radius: 18),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double radius;

  const _SkeletonBlock({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFE6),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _PlantCardItem {
  final String title;
  final List<Color> gradient;
  final String crop;
  final String assetPath;

  const _PlantCardItem(this.title, this.gradient, this.crop, this.assetPath);
}
