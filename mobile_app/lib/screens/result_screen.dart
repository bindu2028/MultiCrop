import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/prediction_response.dart';
import 'disease_info_screen.dart';
import 'chat_screen.dart';
import '../widgets/fade_slide.dart';

class ResultScreen extends StatefulWidget {
  final PredictionResponse result;
  final Uint8List? imageBytes;

  const ResultScreen({super.key, required this.result, this.imageBytes});

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
      appBar: AppBar(
        title: const Text('Disease Analysis'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1B5E20),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Multi-leaf warning banner (L5)
            if (result.multiLeafWarning)
              FadeSlide(
                delay: const Duration(milliseconds: 0),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.layers_rounded, color: Color(0xFFF57F17), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Multiple leaves detected. For the most accurate diagnosis, scan a single isolated leaf.',
                          style: TextStyle(
                            color: Color(0xFF6F5900),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Image Preview if available
            if (widget.imageBytes != null)
              FadeSlide(
                delay: const Duration(milliseconds: 0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFF81C784).withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1B5E20).withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(widget.imageBytes!, fit: BoxFit.cover),
                ),
              ),
            SizedBox(height: widget.imageBytes != null ? 16 : 0),

            // Main Result Card with Disease Name
            FadeSlide(
              delay: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                      color: Color(0xFF1B5E20).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Crop Label
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF81C784).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Color(0xFF81C784).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              result.crop.toUpperCase(),
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          // Disease Name
                          Text(
                            result.isAmbiguous
                                ? '${result.disease} OR ${result.alternativeDiagnosis}'
                                : result.disease,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B5E20),
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Disease Type Badge
                          Row(
                            children: [
                              Container(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(result.diseaseType)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getCategoryColor(result.diseaseType)
                                        .withValues(alpha: 0.3),
                                  ),
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
                              Spacer(),

                              // Confidence Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      badge.background,
                                      badge.background.withValues(alpha: 0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      badge.background == Color(0xFF66BB6A)
                                          ? Icons.check_circle
                                          : Icons.info,
                                      color: badge.foreground,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '$confidence%',
                                      style: TextStyle(
                                        color: badge.foreground,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14),

                          // Confidence Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: result.confidence.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor:
                                  Color(0xFF1B5E20).withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                badge.progress,
                              ),
                            ),
                          ),
                          SizedBox(height: 14),

                          // Description
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF81C784).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Color(0xFF81C784).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF558B2F),
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    result.diseaseExplanation,
                                    style: TextStyle(
                                      color: Color(0xFF456447),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dual diagnosis warning
                          if (result.isAmbiguous &&
                              result.alternativeDiagnosis != null) ...[
                            SizedBox(height: 14),
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
                                  Icon(
                                    Icons.warning_rounded,
                                    color: Color(0xFFF57F17),
                                    size: 18,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Similar Condition: The model also considers "${result.alternativeDiagnosis}". Consult a specialist or retake in better lighting.',
                                      style: TextStyle(
                                        color: Color(0xFF6F5900),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Treatment Plan
            FadeSlide(
              delay: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                      color: Color(0xFF1B5E20).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Treatment Plan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          SizedBox(height: 14),
                          _RemedySectionTile(
                            icon: Icons.flash_on_rounded,
                            title: 'Immediate Action',
                            content: result.remedySections.immediateAction,
                            fallback: 'Act quickly to isolate affected leaves.',
                          ),
                          SizedBox(height: 12),
                          _RemedySectionTile(
                            icon: Icons.local_pharmacy_outlined,
                            title: 'Spray Plan',
                            content: result.remedySections.sprayPlan,
                            fallback: 'Follow label-safe disease spray guidance.',
                          ),
                          SizedBox(height: 12),
                          _RemedySectionTile(
                            icon: Icons.shield_rounded,
                            title: 'Prevention',
                            content: result.remedySections.prevention,
                            fallback: 'Maintain good plant hygiene practices.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Drug Compounds
            if (result.drugCompounds.isNotEmpty)
              FadeSlide(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                        color: Color(0xFF1B5E20).withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Natural Compounds',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: result.drugCompounds.map((compound) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF81C784).withValues(alpha: 0.2),
                                        Color(0xFF66BB6A).withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Color(0xFF81C784)
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.eco_rounded,
                                        size: 16,
                                        color: Color(0xFF81C784),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        compound,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF558B2F),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 16),

            // Severity Card (L1)
            if (result.severityScore > 0)
              FadeSlide(
                delay: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                        color: Color(0xFF1B5E20).withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Disease Severity',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _severityColor(result.severityLabel).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _severityColor(result.severityLabel).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    result.severityLabel.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _severityColor(result.severityLabel),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Score bar
                            Row(
                              children: [
                                Text(
                                  'Severity Score',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF546E7A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${result.severityScore}/10',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: _severityColor(result.severityLabel),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: result.severityScore / 10.0,
                                minHeight: 10,
                                backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _severityColor(result.severityLabel),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Affected area
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF42A5F5).withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.crop_free_rounded,
                                          size: 15, color: Color(0xFF1565C0)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Affected area: ${result.affectedAreaPct}%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1565C0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (result.severityRecommendation.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _severityColor(result.severityLabel).withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _severityColor(result.severityLabel).withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline_rounded,
                                      size: 16,
                                      color: _severityColor(result.severityLabel),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        result.severityRecommendation,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _severityColor(result.severityLabel)
                                              .withValues(alpha: 0.85),
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 16),
            FadeSlide(
              delay: const Duration(milliseconds: 400),
              child: _ModernActionButton(
                icon: Icons.info_outline,
                label: 'Learn More',
                color: Color(0xFF42A5F5),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DiseaseInfoScreen(diseaseName: result.disease),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Retake suggestion
            if (showRetakeSuggestion)
              FadeSlide(
                delay: const Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFFEF5350).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outlined,
                          color: Color(0xFFD32F2F), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Confidence is low. Try capturing a clearer leaf image in better lighting for more accurate diagnosis.',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 20),
          ],
        ),
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

  Color _severityColor(String label) {
    switch (label.toLowerCase()) {
      case 'mild':
        return const Color(0xFF43A047);    // Green
      case 'moderate':
        return const Color(0xFFFB8C00);    // Amber
      case 'severe':
        return const Color(0xFFE53935);    // Red
      case 'critical':
        return const Color(0xFF6A1B9A);    // Deep Purple
      default:
        return const Color(0xFF546E7A);    // Grey
    }
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

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
