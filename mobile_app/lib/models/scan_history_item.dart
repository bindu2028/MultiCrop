class ScanHistoryItem {
  final String crop;
  final String disease;
  final double confidence;
  final DateTime scannedAt;
  final String remedy;
  final String? imageUrl;

  const ScanHistoryItem({
    required this.crop,
    required this.disease,
    required this.confidence,
    required this.scannedAt,
    this.remedy = '',
    this.imageUrl,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      crop: (json['crop'] ?? json['crop_name'] ?? 'unknown').toString(),
      disease: (json['disease'] ?? 'Unknown').toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      scannedAt: DateTime.tryParse((json['scanned_at'] ?? '').toString()) ?? DateTime.now(),
      remedy: (json['remedy'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'disease': disease,
      'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
      'remedy': remedy,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
