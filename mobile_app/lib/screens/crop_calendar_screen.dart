import 'package:flutter/material.dart';

import '../data/crop_calendar.dart';

class CropCalendarScreen extends StatelessWidget {
  const CropCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Crop Calendar', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Season-wise farming tips', style: TextStyle(fontSize: 12, color: Color(0xFF6D7B6F))),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: kCropCalendar.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _CropCalendarCard(crop: kCropCalendar[index]),
      ),
    );
  }
}

class _CropCalendarCard extends StatefulWidget {
  final CropCalendarInfo crop;
  const _CropCalendarCard({required this.crop});

  @override
  State<_CropCalendarCard> createState() => _CropCalendarCardState();
}

class _CropCalendarCardState extends State<_CropCalendarCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3ECE0)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF7EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(crop.emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _MonthChip(label: '🌱 Sow', months: crop.sowingMonths, color: const Color(0xFF4CAF50)),
                            _MonthChip(label: '🌾 Harvest', months: crop.harvestMonths, color: const Color(0xFFE07B39)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF8DA393),
                  ),
                ],
              ),
            ),
          ),
          // ── Expanded Detail ──────────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFEAF1E8)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info chips row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.terrain_outlined, label: crop.soilType),
                      _InfoChip(icon: Icons.water_drop_outlined, label: crop.wateringFrequency),
                      _InfoChip(icon: Icons.wb_sunny_outlined, label: crop.sunlight),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Seasonal Tips',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF37673B)),
                  ),
                  const SizedBox(height: 8),
                  ...crop.seasonalTips.map((tip) => _SeasonTipTile(tip: tip)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final String label;
  final List<String> months;
  final Color color;

  const _MonthChip({required this.label, required this.months, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: ${months.join(', ')}',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDECDA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4F7952)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF3A5C3D), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonTipTile extends StatelessWidget {
  final SeasonTip tip;
  const _SeasonTipTile({required this.tip});

  static const _seasonColors = {
    'Winter': Color(0xFFE0F2FE),
    'Spring': Color(0xFFECFDF5),
    'Summer': Color(0xFFFFF7ED),
    'Autumn': Color(0xFFFEF3C7),
  };

  static const _seasonIconColors = {
    'Winter': Color(0xFF0369A1),
    'Spring': Color(0xFF047857),
    'Summer': Color(0xFFB45309),
    'Autumn': Color(0xFF92400E),
  };

  static const _seasonIcons = {
    'Winter': Icons.ac_unit_rounded,
    'Spring': Icons.local_florist_outlined,
    'Summer': Icons.wb_sunny_outlined,
    'Autumn': Icons.energy_savings_leaf_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = _seasonColors[tip.season] ?? const Color(0xFFF4F9F2);
    final iconColor = _seasonIconColors[tip.season] ?? const Color(0xFF4F7952);
    final icon = _seasonIcons[tip.season] ?? Icons.calendar_month_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.season,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: iconColor),
                  ),
                  const SizedBox(height: 3),
                  Text(tip.tip, style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF374151))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
