import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/plant_care_data.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Per-crop accent colour palette so each crop feels unique
// ═══════════════════════════════════════════════════════════════════════════════
const List<List<Color>> _cropGradients = [
  [Color(0xFFE53935), Color(0xFFFF7043)], // Apple – red
  [Color(0xFF43A047), Color(0xFF66BB6A)], // Bell Pepper – green
  [Color(0xFFAD1457), Color(0xFFE91E63)], // Cherry – pink
  [Color(0xFFF9A825), Color(0xFFFFCA28)], // Corn – gold
  [Color(0xFF6A1B9A), Color(0xFFAB47BC)], // Grape – purple
  [Color(0xFFF57C00), Color(0xFFFFB74D)], // Peach – orange
  [Color(0xFF795548), Color(0xFFA1887F)], // Potato – brown
  [Color(0xFFC62828), Color(0xFFEF5350)], // Strawberry – crimson
  [Color(0xFFE65100), Color(0xFFFF8A65)], // Tomato – deep orange
];

class PlantCareScreen extends StatefulWidget {
  const PlantCareScreen({super.key});

  @override
  State<PlantCareScreen> createState() => _PlantCareScreenState();
}

class _PlantCareScreenState extends State<PlantCareScreen>
    with TickerProviderStateMixin {
  int _selectedCropIndex = 0;
  int _activeTab = 0;
  late final AnimationController _fadeController;
  late final AnimationController _heroController;
  final _scrollController = ScrollController();

  static const _tabs = ['Care', 'Tips', 'Friends', 'Pests'];
  static const _tabIcons = [
    Icons.water_drop_rounded,
    Icons.tips_and_updates_rounded,
    Icons.groups_rounded,
    Icons.bug_report_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450))
      ..forward();
    _heroController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heroController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectCrop(int index) {
    if (index == _selectedCropIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedCropIndex = index);
    _fadeController.forward(from: 0);
    _heroController.forward(from: 0);
  }

  void _selectTab(int index) {
    if (index == _activeTab) return;
    HapticFeedback.lightImpact();
    setState(() => _activeTab = index);
    _fadeController.forward(from: 0);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  List<Color> get _accent => _cropGradients[_selectedCropIndex];

  @override
  Widget build(BuildContext context) {
    final crop = kPlantCareData[_selectedCropIndex];
    final mq = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF5),
        body: Column(
          children: [
            // ═══════════════════ HERO HEADER ═══════════════════
            _HeroHeader(
              crop: crop,
              accent: _accent,
              heroAnimation: _heroController,
              topPadding: mq.padding.top,
              onBack: () => Navigator.pop(context),
            ),

            // ═══════════════════ CROP CAROUSEL ═══════════════════
            Container(
              color: const Color(0xFFF7FAF5),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: kPlantCareData.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final c = kPlantCareData[i];
                        final selected = i == _selectedCropIndex;
                        final grad = _cropGradients[i];
                        return GestureDetector(
                          onTap: () => _selectCrop(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            width: selected ? 80 : 64,
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: grad)
                                  : null,
                              color: selected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? grad[0]
                                    : const Color(0xFFE0E8DD),
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                          color: grad[0].withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.emoji,
                                    style: TextStyle(
                                        fontSize: selected ? 28 : 22)),
                                const SizedBox(height: 4),
                                Text(
                                  c.cropName.split('/')[0].trim(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF6C786D),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ═══════════════════ TAB BAR ═══════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: List.generate(_tabs.length, (i) {
                          final selected = i == _activeTab;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTab(i),
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      selected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(11),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.06),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2))
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_tabIcons[i],
                                        size: 16,
                                        color: selected
                                            ? _accent[0]
                                            : const Color(0xFF9E9E9E)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _tabs[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: selected
                                            ? _accent[0]
                                            : const Color(0xFF9E9E9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),

            // ═══════════════════ TAB CONTENT ═══════════════════
            Expanded(
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _fadeController, curve: Curves.easeIn),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: _fadeController, curve: Curves.easeOut)),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: _buildTabContent(crop),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB CONTENT BUILDER
  // ─────────────────────────────────────────────────────────────────────────
  List<Widget> _buildTabContent(PlantCareInfo crop) {
    switch (_activeTab) {
      case 0:
        return _buildCareTab(crop);
      case 1:
        return _buildTipsTab(crop);
      case 2:
        return _buildCompanionsTab(crop);
      case 3:
        return _buildPestsTab(crop);
      default:
        return [];
    }
  }

  // ── CARE TAB ──
  List<Widget> _buildCareTab(PlantCareInfo crop) {
    final careItems = [
      _CareData(Icons.water_drop_rounded, 'Watering', crop.care.water,
          const Color(0xFF42A5F5), const Color(0xFFE3F2FD)),
      _CareData(Icons.wb_sunny_rounded, 'Sunlight', crop.care.sunlight,
          const Color(0xFFF9A825), const Color(0xFFFFF8E1)),
      _CareData(Icons.landscape_rounded, 'Soil', crop.care.soil,
          const Color(0xFF795548), const Color(0xFFEFEBE9)),
      _CareData(Icons.thermostat_rounded, 'Temperature', crop.care.temperature,
          const Color(0xFFEF5350), const Color(0xFFFFEBEE)),
      _CareData(Icons.cloud_rounded, 'Humidity', crop.care.humidity,
          const Color(0xFF78909C), const Color(0xFFECEFF1)),
      _CareData(Icons.grass_rounded, 'Fertilizer', crop.care.fertilizer,
          const Color(0xFF43A047), const Color(0xFFE8F5E9)),
    ];

    return careItems
        .asMap()
        .entries
        .map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CareCard(data: e.value, index: e.key, accent: _accent),
            ))
        .toList();
  }

  // ── TIPS TAB ──
  List<Widget> _buildTipsTab(PlantCareInfo crop) {
    final widgets = <Widget>[];

    // Common Mistakes
    widgets.add(_SectionLabel(
      icon: Icons.warning_amber_rounded,
      label: 'Avoid These Mistakes',
      color: const Color(0xFFE65100),
    ));
    widgets.add(const SizedBox(height: 10));

    for (int i = 0; i < crop.commonMistakes.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _MistakeCard(index: i, text: crop.commonMistakes[i]),
      ));
    }

    widgets.add(const SizedBox(height: 20));

    // Pro Tips
    widgets.add(_SectionLabel(
      icon: Icons.auto_awesome_rounded,
      label: 'Expert Pro Tips',
      color: _accent[0],
    ));
    widgets.add(const SizedBox(height: 10));

    for (int i = 0; i < crop.proTips.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ProTipCard(index: i, text: crop.proTips[i], accent: _accent),
      ));
    }

    return widgets;
  }

  // ── COMPANIONS TAB ──
  List<Widget> _buildCompanionsTab(PlantCareInfo crop) {
    final widgets = <Widget>[];

    widgets.add(_SectionLabel(
      icon: Icons.diversity_1_rounded,
      label: 'Best Plant Companions',
      color: const Color(0xFF2E7D32),
    ));
    widgets.add(const SizedBox(height: 10));
    widgets.add(const Text(
      'Grow these together for mutual benefits — pest control, better pollination, and nutrient sharing.',
      style: TextStyle(color: Color(0xFF6C786D), fontSize: 13, height: 1.5),
    ));
    widgets.add(const SizedBox(height: 16));

    for (int i = 0; i < crop.companionPlants.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _CompanionCard(
          text: crop.companionPlants[i],
          index: i,
          accent: _accent,
        ),
      ));
    }
    return widgets;
  }

  // ── PESTS TAB ──
  List<Widget> _buildPestsTab(PlantCareInfo crop) {
    final widgets = <Widget>[];
    widgets.add(_SectionLabel(
      icon: Icons.shield_rounded,
      label: 'Pest & Threat Watch',
      color: const Color(0xFFC62828),
    ));
    widgets.add(const SizedBox(height: 6));
    widgets.add(const Text(
      'Know the signs, act fast. Tap a card for details.',
      style: TextStyle(color: Color(0xFF6C786D), fontSize: 13),
    ));
    widgets.add(const SizedBox(height: 16));

    for (int i = 0; i < crop.pestWatch.length; i++) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _PestCard(pest: crop.pestWatch[i], index: i),
      ));
    }
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════════
class _CareData {
  final IconData icon;
  final String label;
  final String description;
  final Color iconColor;
  final Color bgColor;
  const _CareData(
      this.icon, this.label, this.description, this.iconColor, this.bgColor);
}

// ═══════════════════════════════════════════════════════════════════════════════
// HERO HEADER — full-width dark gradient with organic blob shapes
// ═══════════════════════════════════════════════════════════════════════════════
class _HeroHeader extends StatelessWidget {
  final PlantCareInfo crop;
  final List<Color> accent;
  final Animation<double> heroAnimation;
  final double topPadding;
  final VoidCallback onBack;

  const _HeroHeader({
    required this.crop,
    required this.accent,
    required this.heroAnimation,
    required this.topPadding,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A2E1A),
            Color.lerp(const Color(0xFF1A2E1A), accent[0], 0.35)!,
            accent[0].withValues(alpha: 0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: topPadding - 10,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent[1].withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button row
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Plant Care',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent[0].withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: accent[1].withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded,
                              color: accent[1], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Guide',
                            style: TextStyle(
                              color: accent[1],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Crop info row
                FadeTransition(
                  opacity: CurvedAnimation(
                      parent: heroAnimation, curve: Curves.easeIn),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: heroAnimation, curve: Curves.easeOut)),
                    child: Row(
                      children: [
                        // Emoji container with glow
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent[0].withValues(alpha: 0.3),
                                accent[1].withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: accent[1].withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                  color: accent[0].withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(crop.emoji,
                              style: const TextStyle(fontSize: 38)),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop.cropName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Complete growing & care guide',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CARE CARD — horizontal card with left accent stripe
// ═══════════════════════════════════════════════════════════════════════════════
class _CareCard extends StatelessWidget {
  final _CareData data;
  final int index;
  final List<Color> accent;
  const _CareCard(
      {required this.data, required this.index, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: data.iconColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent stripe
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [data.iconColor, data.iconColor.withValues(alpha: 0.4)],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: data.bgColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            Icon(data.icon, color: data.iconColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.label,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: data.iconColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data.description,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF5D6B5E),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISTAKE CARD — numbered with warning gradient
// ═══════════════════════════════════════════════════════════════════════════════
class _MistakeCard extends StatelessWidget {
  final int index;
  final String text;
  const _MistakeCard({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFFFF3E0).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2).withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4E342E),
                      height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRO TIP CARD — with glow effect
// ═══════════════════════════════════════════════════════════════════════════════
class _ProTipCard extends StatelessWidget {
  final int index;
  final String text;
  final List<Color> accent;
  const _ProTipCard(
      {required this.index, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: accent[0].withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: accent[0].withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: accent),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: accent[0].withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1B5E20),
                      height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPANION CARD — individual card per companion
// ═══════════════════════════════════════════════════════════════════════════════
class _CompanionCard extends StatelessWidget {
  final String text;
  final int index;
  final List<Color> accent;
  const _CompanionCard(
      {required this.text, required this.index, required this.accent});

  static const _plantEmojis = ['🌿', '🌻', '🌾', '🍃', '🌸', '☘️'];

  @override
  Widget build(BuildContext context) {
    final parts = text.split(' — ');
    final name = parts[0];
    final desc = parts.length > 1 ? parts[1] : '';
    final emoji = _plantEmojis[index % _plantEmojis.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFE8F5E9).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E8D3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent[0].withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent[0].withValues(alpha: 0.12)),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: accent[0],
                        fontSize: 15)),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(desc,
                      style: const TextStyle(
                          color: Color(0xFF6C786D),
                          fontSize: 12,
                          height: 1.35)),
                ],
              ],
            ),
          ),
          Icon(Icons.handshake_rounded,
              color: accent[0].withValues(alpha: 0.2), size: 22),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PEST CARD — expandable with threat-level visual
// ═══════════════════════════════════════════════════════════════════════════════
class _PestCard extends StatefulWidget {
  final PestInfo pest;
  final int index;
  const _PestCard({required this.pest, required this.index});

  @override
  State<_PestCard> createState() => _PestCardState();
}

class _PestCardState extends State<_PestCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _expandAnimation = CurvedAnimation(
        parent: _expandController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  static const _threatColors = [
    Color(0xFFE53935),
    Color(0xFFFF6F00),
    Color(0xFFFF8F00),
  ];

  @override
  Widget build(BuildContext context) {
    final threatColor = _threatColors[widget.index % _threatColors.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _expanded ? threatColor.withValues(alpha: 0.4) : const Color(0xFFEEEEEE),
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: _expanded
            ? [
                BoxShadow(
                    color: threatColor.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ]
            : [
                const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 8,
                    offset: Offset(0, 2))
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Threat level icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            threatColor.withValues(alpha: 0.15),
                            threatColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: threatColor.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.pest_control_rounded,
                          color: threatColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pest.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: threatColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap for signs & solutions',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Threat dots
                    Row(
                      children: List.generate(
                          3,
                          (i) => Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i <= widget.index % 3
                                        ? threatColor
                                        : threatColor.withValues(alpha: 0.15),
                                  ),
                                ),
                              )),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 350),
                      child: Icon(Icons.expand_more_rounded,
                          color: threatColor.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                // Expanded content
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        _pestSection(
                          icon: Icons.visibility_rounded,
                          label: 'Signs to Watch',
                          text: widget.pest.signs,
                          color: const Color(0xFFE65100),
                          bgColor: const Color(0xFFFFF3E0),
                        ),
                        const SizedBox(height: 10),
                        _pestSection(
                          icon: Icons.verified_rounded,
                          label: 'Solution',
                          text: widget.pest.solution,
                          color: const Color(0xFF2E7D32),
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pestSection({
    required IconData icon,
    required String label,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(text,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
