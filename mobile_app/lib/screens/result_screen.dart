import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prediction_response.dart';
import 'disease_info_screen.dart';
import 'chat_screen.dart';
import 'disease_simulator_screen.dart';
import '../widgets/fade_slide.dart';

class ResultScreen extends StatefulWidget {
  final PredictionResponse result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final List<String> _treatmentSteps;
  final Set<int> _completedSteps = <int>{};

  @override
  void initState() {
    super.initState();
    _treatmentSteps = _buildTreatmentSteps(widget.result);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final confidence = (result.confidence * 100).clamp(0, 100).toStringAsFixed(1);
    final badge = _confidenceBadge(result.confidence);
    final showRetakeSuggestion = result.confidence < 0.7 || result.isUncertain;

    return Scaffold(
      appBar: AppBar(title: const Text('Prediction Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlide(
            delay: const Duration(milliseconds: 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crop: ${result.crop.toUpperCase()}'),
                  const SizedBox(height: 8),
                  Text(
                    result.disease,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF7EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD7E8D3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 18, color: Color(0xFF467247)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.diseaseExplanation,
                                style: const TextStyle(
                                  color: Color(0xFF456447),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text(
                              'Category:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF467247),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(result.diseaseType).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _getCategoryColor(result.diseaseType).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                result.diseaseType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: _getCategoryColor(result.diseaseType),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text('Confidence: $confidence%')),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badge.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge.label,
                          style: TextStyle(
                            color: badge.foreground,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: result.confidence.clamp(0, 1),
                    color: badge.progress,
                  ),
                  const SizedBox(height: 14),
                  const Text('Remedy Summary', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ...result.remedy.split(RegExp(r'[.;]\s?')).map((point) {
                    final trimmed = point.trim();
                    if (trimmed.isEmpty || trimmed.length < 3) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF467247),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              trimmed,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Color(0xFF2E3D2E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (result.drugCompounds.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Natural Drug Compounds', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.drugCompounds.map((compound) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4EF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E5DF)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.medication_outlined, size: 14, color: Color(0xFF467247)),
                              const SizedBox(width: 6),
                              Text(
                                compound,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF324D36),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (result.isUncertain) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Confidence is low. Capture a clearer leaf image and retry.',
                      style: TextStyle(color: Color(0xFFB26A00)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 14),
          FadeSlide(
            delay: const Duration(milliseconds: 150),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Treatment Plan', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _RemedySectionTile(
                    icon: Icons.bolt_rounded,
                    title: 'Immediate Action',
                    content: result.remedySections.immediateAction,
                    fallback: 'Act quickly to isolate affected leaves and prevent spread.',
                  ),
                  const SizedBox(height: 10),
                  _RemedySectionTile(
                    icon: Icons.shield_moon_outlined,
                    title: 'Spray Plan',
                    content: result.remedySections.sprayPlan,
                    fallback: 'Follow label-safe disease spray guidance at regular intervals.',
                  ),
                  const SizedBox(height: 10),
                  _RemedySectionTile(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Prevention',
                    content: result.remedySections.prevention,
                    fallback: 'Improve airflow, hygiene, and watering practice to avoid recurrence.',
                  ),
                  const SizedBox(height: 10),
                  _RemedySectionTile(
                    icon: Icons.track_changes_outlined,
                    title: 'Monitoring',
                    content: result.remedySections.monitoring,
                    fallback: 'Re-scan in a few days and compare symptom progression.',
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 14),
          FadeSlide(
            delay: const Duration(milliseconds: 300),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _copySummary,
                        icon: const Icon(Icons.copy_all_outlined),
                        label: const Text('Copy Summary'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Retake'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => DiseaseInfoScreen(diseaseName: result.disease),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline_rounded),
                        label: const Text('Disease Info'),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => ChatScreen(crop: result.crop, disease: result.disease),
                          ),
                        ),
                        icon: const Icon(Icons.smart_toy_outlined),
                        label: const Text('Ask AI'),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1C7C44), foregroundColor: Colors.white),
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => DiseaseSimulatorScreen(diseaseName: result.disease),
                          ),
                        ),
                        icon: const Icon(Icons.fast_forward_rounded),
                        label: const Text('Simulate Progression'),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
          const SizedBox(height: 14),
          FadeSlide(
            delay: const Duration(milliseconds: 450),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Treatment Checklist', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...List.generate(_treatmentSteps.length, (index) {
                    final done = _completedSteps.contains(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            if (done) {
                              _completedSteps.remove(index);
                            } else {
                              _completedSteps.add(index);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: done ? const Color(0xFFE9F7EE) : const Color(0xFFF7FAF7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: done ? const Color(0xFFBDE3C8) : const Color(0xFFE1E9E1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                done ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 20,
                                color: done ? const Color(0xFF2B8A4B) : const Color(0xFF809080),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _treatmentSteps[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: done ? const Color(0xFF2E4D35) : const Color(0xFF324D36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Text(
                    '${_completedSteps.length}/${_treatmentSteps.length} completed',
                    style: const TextStyle(
                      color: Color(0xFF647564),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          if (showRetakeSuggestion) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Retake Suggestion',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This prediction has low confidence. Capture a close-up leaf image in bright light and try again.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Retake Image'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Probability Breakdown', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (result.probabilities.isEmpty)
                    const Text('No probability data available.')
                  else
                    ...result.probabilities.entries.map((entry) {
                      final percent = (entry.value * 100).clamp(0, 100).toStringAsFixed(1);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(entry.key)),
                                Text('$percent%'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: entry.value.clamp(0, 1)),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copySummary() async {
    final result = widget.result;
    final confidence = (result.confidence * 100).clamp(0, 100).toStringAsFixed(1);
    final summary = 'Crop: ${result.crop} | Diagnosis: ${result.disease} (${result.diseaseType}) | Confidence: $confidence% | Remedy: ${result.remedy} | Compounds: ${result.drugCompounds.join(', ')}';
    await Clipboard.setData(ClipboardData(text: summary));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result summary copied')),
    );
  }

  List<String> _buildTreatmentSteps(PredictionResponse result) {
    final structured = <String>[
      result.remedySections.immediateAction,
      result.remedySections.sprayPlan,
      result.remedySections.prevention,
      result.remedySections.monitoring,
    ].where((step) => step.trim().isNotEmpty).toList();

    if (structured.isNotEmpty) {
      return structured;
    }

    final normalized = result.remedy.replaceAll('\n', '. ');
    final parts = normalized
        .split(RegExp(r'[.;]'))
        .map((item) => item.trim())
        .where((item) => item.length > 6)
        .toList();

    if (parts.isEmpty) {
      return <String>['Follow the suggested remedy carefully and monitor the plant daily.'];
    }

    return parts;
  }

  _ConfidenceBadge _confidenceBadge(double confidence) {
    if (confidence >= 0.85) {
      return const _ConfidenceBadge(
        label: 'HIGH',
        background: Color(0xFFE6F7EA),
        foreground: Color(0xFF1B7F3D),
        progress: Color(0xFF1B7F3D),
      );
    }
    if (confidence >= 0.6) {
      return const _ConfidenceBadge(
        label: 'MEDIUM',
        background: Color(0xFFFFF4DE),
        foreground: Color(0xFFA06A00),
        progress: Color(0xFFCC9600),
      );
    }
    return const _ConfidenceBadge(
      label: 'LOW',
      background: Color(0xFFFFE5E5),
      foreground: Color(0xFFB42318),
      progress: Color(0xFFB42318),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'bacterial':
        return const Color(0xFFE53935);
      case 'fungal':
        return const Color(0xFFFB8C00);
      case 'pest':
      case 'pests':
        return const Color(0xFF43A047);
      case 'virus':
        return const Color(0xFF8E24AA);
      default:
        return const Color(0xFF546E7A);
    }
  }
}

class _ConfidenceBadge {
  final String label;
  final Color background;
  final Color foreground;
  final Color progress;

  const _ConfidenceBadge({
    required this.label,
    required this.background,
    required this.foreground,
    required this.progress,
  });
}

class _RemedySectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final String fallback;

  const _RemedySectionTile({
    required this.icon,
    required this.title,
    required this.content,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final text = content.trim().isEmpty ? fallback : content;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3ECE0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF67B15A).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: const Color(0xFF3F8649)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(color: Color(0xFF4E6352))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
