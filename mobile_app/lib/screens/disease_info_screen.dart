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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Treatment'),
              Tab(text: 'Prevention'),
            ],
          ),
        ),
        body: info == null
            ? _NotFoundView(diseaseName: diseaseName)
            : TabBarView(
                children: [
                  _OverviewTab(info: info),
                  _TreatmentTab(info: info),
                  _PreventionTab(info: info),
                ],
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
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF047857).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_outlined, color: Color(0xFF047857), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Organic / Natural',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF065F46)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(info.organicTreatment, style: const TextStyle(color: Color(0xFF1F4F3A), height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.science_outlined, color: Color(0xFF1D4ED8), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Chemical Treatment',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E3A8A)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(info.chemicalTreatment, style: const TextStyle(color: Color(0xFF1E3A8A), height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Always follow label instructions and local regulations before applying any pesticide.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}
