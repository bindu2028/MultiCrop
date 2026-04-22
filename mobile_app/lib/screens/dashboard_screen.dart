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

class _DashboardScreenState extends State<DashboardScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<ScanHistoryItem>> _historyFuture;

  final List<_PlantCardItem> _modelCrops = const [
    _PlantCardItem('Apple', '4 disease classes', [Color(0xFF7DBA5D), Color(0xFF467F37)], 'apple'),
    _PlantCardItem('Bell Pepper', '2 disease classes', [Color(0xFF6DBB68), Color(0xFF4C9751)], 'bell_pepper'),
    _PlantCardItem('Cherry', '2 disease classes', [Color(0xFFF0A55B), Color(0xFFE37C2F)], 'cherry'),
    _PlantCardItem('Corn / Maize', '4 disease classes', [Color(0xFF84C35F), Color(0xFF4D8D37)], 'corn_maize'),
    _PlantCardItem('Grape', '4 disease classes', [Color(0xFF67A881), Color(0xFF306B46)], 'grape'),
    _PlantCardItem('Peach', '2 disease classes', [Color(0xFFF1AD6A), Color(0xFFEA8742)], 'peach'),
    _PlantCardItem('Potato', '3 disease classes', [Color(0xFF9AB65D), Color(0xFF6C8D35)], 'potato'),
    _PlantCardItem('Strawberry', '2 disease classes', [Color(0xFFF28A90), Color(0xFFCC4E5E)], 'strawberry'),
    _PlantCardItem('Tomato', '6 disease classes', [Color(0xFF6DBF62), Color(0xFF2F8740)], 'tomato'),
  ];

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.loadHistory();
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
          return const Center(child: CircularProgressIndicator());
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
                    return _ModelCropCard(
                      item: item,
                      onTap: () => widget.onScanRequested(item.crop),
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
              Positioned(
                top: -8,
                right: -8,
                child: Icon(Icons.eco_outlined, color: Colors.white.withValues(alpha: 0.15), size: 78),
              ),
              Positioned(
                bottom: -12,
                left: -12,
                child: Icon(Icons.spa_outlined, color: Colors.white.withValues(alpha: 0.10), size: 92),
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

class _PlantCardItem {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String crop;

  const _PlantCardItem(this.title, this.subtitle, this.gradient, this.crop);
}
