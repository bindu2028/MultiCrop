class PredictionResponse {
  final String crop;
  final String disease;
  final double confidence;
  final String remedy;
  final bool isUncertain;
  final Map<String, double> probabilities;

  const PredictionResponse({
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.remedy,
    required this.isUncertain,
    required this.probabilities,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final probabilities = (json['probabilities'] as Map<String, dynamic>? ?? <String, dynamic>{})
        .map((key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0));

    return PredictionResponse(
      crop: (json['crop'] ?? 'unknown').toString(),
      disease: (json['disease'] ?? 'Unknown').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      remedy: (json['remedy'] ?? 'No remedy available.').toString(),
      isUncertain: (json['is_uncertain'] as bool?) ?? false,
      probabilities: probabilities,
    );
  }
}
