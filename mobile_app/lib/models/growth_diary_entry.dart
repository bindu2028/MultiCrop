class GrowthDiaryEntry {
  final String id;
  final String crop;
  final String observation;
  final String? disease;
  final String? imageBase64;
  final DateTime createdAt;

  const GrowthDiaryEntry({
    required this.id,
    required this.crop,
    required this.observation,
    required this.createdAt,
    this.disease,
    this.imageBase64,
  });

  factory GrowthDiaryEntry.fromJson(Map<String, dynamic> json) {
    return GrowthDiaryEntry(
      id: (json['id'] ?? '').toString(),
      crop: (json['crop'] ?? 'unknown').toString(),
      observation: (json['observation'] ?? '').toString(),
      disease: json['disease']?.toString(),
      imageBase64: json['image_base64']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop': crop,
      'observation': observation,
      'disease': disease,
      'image_base64': imageBase64,
      'created_at': createdAt.toIso8601String(),
    };
  }
}