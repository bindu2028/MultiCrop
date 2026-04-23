import 'package:flutter/material.dart';

import '../models/scan_history_item.dart';
import '../services/history_service.dart';

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

  final List<_PlantCardItem> _modelCrops = const [
    _PlantCardItem('Apple', '4 disease classes', [Color(0xFF78B256), Color(0xFF3D7135)], 'apple', 'assets/images/crops/apple.jpg'),
    _PlantCardItem('Bell Pepper', '2 disease classes', [Color(0xFF63B45E), Color(0xFF377F4A)], 'bell_pepper', 'assets/images/crops/bell_pepper.jpg'),
    _PlantCardItem('Cherry', '2 disease classes', [Color(0xFF80B96C), Color(0xFF4B7D3B)], 'cherry', 'assets/images/crops/cherry.jpg'),
    _PlantCardItem('Corn / Maize', '4 disease classes', [Color(0xFF85C161), Color(0xFF4D8D37)], 'corn_maize', 'assets/images/crops/corn_maize.jpg'),
    _PlantCardItem('Grape', '4 disease classes', [Color(0xFF6DAA75), Color(0xFF356947)], 'grape', 'assets/images/crops/grape.jpg'),
    _PlantCardItem('Peach', '2 disease classes', [Color(0xFF7EB65A), Color(0xFF4C7D37)], 'peach', 'assets/images/crops/peach.jpg'),
    _PlantCardItem('Potato', '3 disease classes', [Color(0xFF93B963), Color(0xFF5D8138)], 'potato', 'assets/images/crops/potato.jpg'),
    _PlantCardItem('Strawberry', '2 disease classes', [Color(0xFF71B864), Color(0xFF3C7E43)], 'strawberry', 'assets/images/crops/strawberry.jpg'),
    _PlantCardItem('Tomato', '6 disease classes', [Color(0xFF66B85C), Color(0xFF2E8040)], 'tomato', 'assets/images/crops/tomato.jpg'),
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
                _SectionHeader(
                  title: 'Model Crops',
                  actionLabel: 'Show More',
                  onActionTap: () => widget.onNavigateToTab(2),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _modelCrops.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.92,
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
                const SizedBox(height: 18),
                _QuickToolsCard(
                  onIdentify: widget.onScanRequested,
                  onDiagnose: widget.onScanRequested,
                  onHistory: () => widget.onNavigateToTab(2),
                ),
                const SizedBox(height: 18),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E2), Color(0xFFF4FBF1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E8D3)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
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
                  'Explore',
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
                      colors: [Color(0x1F000000), Color(0x8C000000)],
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
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
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
  final void Function([String? crop]) onIdentify;
  final void Function([String? crop]) onDiagnose;
  final VoidCallback onHistory;

  const _QuickToolsCard({
    required this.onIdentify,
    required this.onDiagnose,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8E0)),
      ),
      child: Column(
        children: [
          _ToolRow(
            icon: Icons.photo_camera_outlined,
            title: 'Identify',
            subtitle: 'Recognize a plant',
            onTap: onIdentify,
          ),
          const SizedBox(height: 10),
          _ToolRow(
            icon: Icons.health_and_safety_outlined,
            title: 'Diagnose',
            subtitle: 'Check plant health',
            onTap: onDiagnose,
          ),
          const SizedBox(height: 10),
          _ToolRow(
            icon: Icons.history_outlined,
            title: 'Recent scans',
            subtitle: 'Review saved results',
            onTap: onHistory,
          ),
        ],
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
  final String subtitle;
  final List<Color> gradient;
  final String crop;
  final String assetPath;

  const _PlantCardItem(this.title, this.subtitle, this.gradient, this.crop, this.assetPath);
}
