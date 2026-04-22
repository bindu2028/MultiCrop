import 'package:flutter/material.dart';

import '../models/prediction_response.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResponse result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
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
