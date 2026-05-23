import 'dart:ui';
import 'package:flutter/material.dart';

import '../data/disease_knowledge.dart';

class DiseaseInfoScreen extends StatelessWidget {
  final String diseaseName;

  const DiseaseInfoScreen({super.key, required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    final info = lookupDisease(diseaseName);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(info?.name ?? diseaseName),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1B5E20),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF81C784).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.visibility_outlined, size: 18),
                    text: 'Overview',
                  ),
                  Tab(
                    icon: Icon(Icons.healing_outlined, size: 18),
                    text: 'Treatment',
                  ),
                  Tab(
                    icon: Icon(Icons.shield_rounded, size: 18),
                    text: 'Prevention',
                  ),
                ],
                labelColor: Color(0xFF81C784),
                unselectedLabelColor: Color(0xFF99A399),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                indicatorColor: Color(0xFF81C784),
                indicatorWeight: 3,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF81C784).withValues(alpha: 0.08),
                Color(0xFF42A5F5).withValues(alpha: 0.08),
              ],
            ),
          ),
          child: info == null
              ? _NotFoundView(diseaseName: diseaseName)
              : TabBarView(
                  children: [
                    _OverviewTab(info: info),
                    _TreatmentTab(info: info),
                    _PreventionTab(info: info),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Not Found ─────────────────────────────────────────────────────────────────

class _NotFoundView extends StatelessWidget {
  final String diseaseName;
  const _NotFoundView({required this.diseaseName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: Color(0xFF8DA393)),
            const SizedBox(height: 16),
            Text(
              'No data found for "$diseaseName"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our knowledge base is growing. Check back after an update.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF647265)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final DiseaseInfo info;
  const _OverviewTab({required this.info});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          icon: Icons.visibility_outlined,
          title: 'Symptoms',
          content: info.symptoms,
          color: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFB45309),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.biotech_outlined,
          title: 'Causes',
          content: info.causes,
          color: const Color(0xFFFFE4E6),
          iconColor: const Color(0xFFBE123C),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.share_outlined,
          title: 'How It Spreads',
          content: info.spread,
          color: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF6D28D9),
        ),
      ],
    );
  }
}

// ── Treatment Tab ─────────────────────────────────────────────────────────────

class _TreatmentTab extends StatelessWidget {
  final DiseaseInfo info;
  const _TreatmentTab({required this.info});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Organic Treatment
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.90),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1B5E20).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.eco_outlined, color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Organic / Natural',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      info.organicTreatment,
                      style: TextStyle(
                        color: Color(0xFF456447),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 14),

        // Chemical Treatment
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.90),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1B5E20).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.science_outlined, color: Colors.white, size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Chemical Treatment',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      info.chemicalTreatment,
                      style: TextStyle(
                        color: Color(0xFF456447),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 14),

        // Warning
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFFFF59D).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFFFBC02D).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_rounded, color: Color(0xFFF57F17), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Always follow label instructions and local regulations before applying any pesticide.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F5900),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Prevention Tab ────────────────────────────────────────────────────────────

class _PreventionTab extends StatelessWidget {
  final DiseaseInfo info;
  const _PreventionTab({required this.info});

  @override
  Widget build(BuildContext context) {
    // Split prevention text into bullet points by sentence
    final tips = info.prevention
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7EC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7E8D3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF2E7D32), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Prevention Tips',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(tip.trim(), style: const TextStyle(color: Color(0xFF2E4D35), height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared Info Card ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.90),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1B5E20).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [iconColor, iconColor.withValues(alpha: 0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  content,
                  style: TextStyle(
                    color: Color(0xFF456447),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
