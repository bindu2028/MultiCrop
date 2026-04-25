class PredictionResponse {
  final String crop;
  final String disease;
  final String diseaseExplanation;
  final double confidence;
  final String remedy;
  final RemedySections remedySections;
  final bool isUncertain;
  final Map<String, double> probabilities;
  final String diseaseType;
  final List<String> drugCompounds;

  const PredictionResponse({
    required this.crop,
    required this.disease,
    required this.diseaseExplanation,
    required this.confidence,
    required this.remedy,
    required this.remedySections,
    required this.isUncertain,
    required this.probabilities,
    required this.diseaseType,
    required this.drugCompounds,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final probabilities = (json['probabilities'] as Map<String, dynamic>? ?? <String, dynamic>{})
        .map((key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0));

    return PredictionResponse(
      crop: (json['crop'] ?? 'unknown').toString(),
      disease: (json['disease'] ?? 'Unknown').toString(),
      diseaseExplanation: (json['disease_explanation'] ?? 'This is a leaf health issue detected by the model.').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      remedy: (json['remedy'] ?? 'No remedy available.').toString(),
      remedySections: RemedySections.fromJson(
        json['remedy_sections'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      isUncertain: (json['is_uncertain'] as bool?) ?? false,
      probabilities: probabilities,
      diseaseType: (json['disease_type'] ?? 'Unknown').toString(),
      drugCompounds: (json['drug_compounds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class RemedySections {
  final String immediateAction;
  final String sprayPlan;
  final String prevention;
  final String monitoring;

  const RemedySections({
    required this.immediateAction,
    required this.sprayPlan,
    required this.prevention,
    required this.monitoring,
  });

  bool get hasStructuredData {
    return immediateAction.isNotEmpty ||
        sprayPlan.isNotEmpty ||
        prevention.isNotEmpty ||
        monitoring.isNotEmpty;
  }

  factory RemedySections.fromJson(Map<String, dynamic> json) {
    return RemedySections(
      immediateAction: (json['immediate_action'] ?? '').toString().trim(),
      sprayPlan: (json['spray_plan'] ?? '').toString().trim(),
      prevention: (json['prevention'] ?? '').toString().trim(),
      monitoring: (json['monitoring'] ?? '').toString().trim(),
    );
  }
}
