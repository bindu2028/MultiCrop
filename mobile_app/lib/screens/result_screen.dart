import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prediction_response.dart';

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
    _treatmentSteps = _buildTreatmentSteps(widget.result.remedy);
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
          Card(
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
                  const Text('Remedy', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(result.remedy),
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
          const SizedBox(height: 14),
          Card(
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
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
    final summary = 'Crop: ${result.crop} | Diagnosis: ${result.disease} | Confidence: $confidence% | Remedy: ${result.remedy}';
    await Clipboard.setData(ClipboardData(text: summary));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result summary copied')),
    );
  }

  List<String> _buildTreatmentSteps(String remedy) {
    final normalized = remedy.replaceAll('\n', '. ');
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
