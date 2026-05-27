import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/herb_library_data.dart';
import '../services/compound_api.dart';
import '../module2/compound_detail_screen.dart';

class HerbDetailScreen extends StatefulWidget {
  final HerbItem herb;
  const HerbDetailScreen({super.key, required this.herb});

  @override
  State<HerbDetailScreen> createState() => _HerbDetailScreenState();
}

class _HerbDetailScreenState extends State<HerbDetailScreen> {
  bool _loadingCompound = false;

  void _navigateToCompound(BuildContext context, String name) async {
    setState(() => _loadingCompound = true);
    HapticFeedback.mediumImpact();
    
    try {
      final data = await CompoundApi.getCompoundFull(name);
      if (!context.mounted) return;
      setState(() => _loadingCompound = false);

      if (data != null && (data['found_in_pubchem'] == true || data['found_in_knowledge_base'] == true)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompoundDetailScreen(data: data),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFC62828),
            content: Text('Could not find chemical details for "$name".'),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      setState(() => _loadingCompound = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFC62828),
          content: Text('Error connecting to database. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.herb;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 🌿 SLIVER APP BAR (BOTANICAL HERO HEADER)
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF1B5E20),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Color(0x3D000000), // equivalent to Colors.black24
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                  title: Text(
                    h.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 22,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Dark green visual backdrop with circular overlays
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F4D2D), Color(0xFF2E7D32)],
                          ),
                        ),
                      ),
                      Positioned(
                        right: -40,
                        top: -20,
                        child: Text(
                          h.emoji,
                          style: TextStyle(
                            fontSize: 180,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Text(
                              h.emoji,
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              h.scientificName,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 1))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🌿 BOTANICAL PROFILE BODY
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Botanical description Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFE0E8DD)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Botanical Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              h.description,
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.45,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F8E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFDCEDC8)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.map_outlined, color: Color(0xFF558B2F), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      h.geographicalRegion,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF33691E),
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

                    const SizedBox(height: 18),

                    // 2. Active compounds Deck
                    const Text(
                      'Active Medicinal Compounds',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap any element to view chemical structures and clinical properties.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: h.activeCompounds.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final c = h.activeCompounds[i];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _navigateToCompound(context, c),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 160,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.science, color: Colors.white, size: 22),
                                    const Spacer(),
                                    Text(
                                      c,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Tap to explore structures ➔',
                                      style: TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Cultivation Stats Dashboard
                    const Text(
                      'Ideal Growing & Cultivation Stats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _buildGrowingMetricCard(
                          icon: Icons.science_outlined,
                          color: const Color(0xFFE0F7FA),
                          iconColor: const Color(0xFF00838F),
                          label: 'Soil pH Range',
                          value: '${h.soilPh} pH',
                        ),
                        _buildGrowingMetricCard(
                          icon: Icons.water_drop_outlined,
                          color: const Color(0xFFE3F2FD),
                          iconColor: const Color(0xFF1565C0),
                          label: 'Water Requirement',
                          value: h.waterNeeds,
                        ),
                        _buildGrowingMetricCard(
                          icon: Icons.wb_sunny_outlined,
                          color: const Color(0xFFFFF8E1),
                          iconColor: const Color(0xFFFF8F00),
                          label: 'Sunlight Level',
                          value: h.sunExposure,
                        ),
                        _buildGrowingMetricCard(
                          icon: Icons.thermostat_outlined,
                          color: const Color(0xFFFFEBEE),
                          iconColor: const Color(0xFFC62828),
                          label: 'Ideal Temp',
                          value: h.tempRange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildGrowingMetricCardWide(
                      icon: Icons.hourglass_empty_rounded,
                      color: const Color(0xFFECEFF1),
                      iconColor: const Color(0xFF37474F),
                      label: 'Sprout to Harvest Cycle',
                      value: h.harvestTime,
                    ),

                    const SizedBox(height: 24),

                    // 4. Traditional Preparation Remedies
                    const Text(
                      'Traditional Preparation & Recipes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...h.traditionalRemedies.map((recipe) {
                      final parts = recipe.split(': ');
                      final title = parts[0];
                      final body = parts.length > 1 ? parts[1] : '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE0E8DD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book_rounded, color: Color(0xFF7CB342), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5,
                                    color: Color(0xFF33691E),
                                  ),
                                ),
                              ],
                            ),
                            if (body.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                body,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),

          // LOADING MODAL FOR SEARCHING COMPOUNDS
          if (_loadingCompound)
            Container(
              color: Colors.black45,
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4CAF50)),
                        SizedBox(height: 16),
                        Text(
                          'Fetching PubChem data...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrowingMetricCard({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowingMetricCardWide({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8DD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B5E20),
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
