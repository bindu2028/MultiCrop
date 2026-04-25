import 'package:flutter/material.dart';

import '../models/scan_history_item.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  late Future<List<ScanHistoryItem>> _historyFuture;
  String _selectedCropFilter = 'all';

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
          return const _HistorySkeleton();
        }

        final history = snapshot.data ?? const [];
        if (history.isEmpty) {
          return const Center(child: Text('No scan history yet.'));
        }

        final cropOptions = history
            .map((item) => item.crop)
            .toSet()
            .toList()
          ..sort();

        final filteredHistory = _selectedCropFilter == 'all'
            ? history
            : history.where((item) => item.crop == _selectedCropFilter).toList();

        return Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent scans',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _historyService.clearHistory();
                    await _refresh();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCropFilter == 'all',
                      onSelected: (_) => setState(() => _selectedCropFilter = 'all'),
                    ),
                  ),
                  ...cropOptions.map(
                    (crop) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(crop.replaceAll('_', ' ')),
                        selected: _selectedCropFilter == crop,
                        onSelected: (_) => setState(() => _selectedCropFilter = crop),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    final confidence = (item.confidence * 100).clamp(0, 100).toStringAsFixed(1);
                    final badge = _confidenceBadge(item.confidence);
                    final when = item.scannedAt.toLocal().toString().substring(0, 16);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: badge.background,
                          child: Icon(Icons.eco_outlined, color: badge.foreground),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(item.disease)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badge.background,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                badge.label,
                                style: TextStyle(
                                  color: badge.foreground,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('Crop: ${item.crop} | $confidence% | $when'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _ConfidenceBadge _confidenceBadge(double confidence) {
    if (confidence >= 0.85) {
      return const _ConfidenceBadge(
        label: 'HIGH',
        background: Color(0xFFE6F7EA),
        foreground: Color(0xFF1B7F3D),
      );
    }
    if (confidence >= 0.6) {
      return const _ConfidenceBadge(
        label: 'MEDIUM',
        background: Color(0xFFFFF4DE),
        foreground: Color(0xFFA06A00),
      );
    }
    return const _ConfidenceBadge(
      label: 'LOW',
      background: Color(0xFFFFE5E5),
      foreground: Color(0xFFB42318),
    );
  }
}

class _ConfidenceBadge {
  final String label;
  final Color background;
  final Color foreground;

  const _ConfidenceBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: _HistorySkeletonBlock(height: 22, radius: 8)),
            SizedBox(width: 70),
          ],
        ),
        const SizedBox(height: 12),
        const _HistorySkeletonBlock(height: 34, radius: 999),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const _HistorySkeletonBlock(height: 84, radius: 16),
          ),
        ),
      ],
    );
  }
}

class _HistorySkeletonBlock extends StatelessWidget {
  final double height;
  final double radius;

  const _HistorySkeletonBlock({required this.height, required this.radius});

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
