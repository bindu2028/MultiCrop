import 'dart:convert';

class DiaryLog {
  final String id;
  final DateTime date;
  final String note;
  final String actionType; // e.g. "Watered", "Fertilized", "Note", "Photo"
  final String? imagePath; // optional path to a local image

  DiaryLog({
    required this.id,
    required this.date,
    required this.note,
    required this.actionType,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'note': note,
        'actionType': actionType,
        'imagePath': imagePath,
      };

  factory DiaryLog.fromJson(Map<String, dynamic> json) => DiaryLog(
        id: json['id'],
        date: DateTime.parse(json['date']),
        note: json['note'],
        actionType: json['actionType'],
        imagePath: json['imagePath'],
      );
}

class PlantTracker {
  final String id;
  final String plantName; // Custom name given by user, e.g. "Front Yard Tomato"
  final String crop; // The base crop type, e.g. "Tomato"
  final DateTime dateAdded;
  final List<DiaryLog> logs;

  PlantTracker({
    required this.id,
    required this.plantName,
    required this.crop,
    required this.dateAdded,
    this.logs = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantName': plantName,
        'crop': crop,
        'dateAdded': dateAdded.toIso8601String(),
        'logs': logs.map((x) => x.toJson()).toList(),
      };

  factory PlantTracker.fromJson(Map<String, dynamic> json) => PlantTracker(
        id: json['id'],
        plantName: json['plantName'],
        crop: json['crop'],
        dateAdded: DateTime.parse(json['dateAdded']),
        logs: List<DiaryLog>.from((json['logs'] as List).map((x) => DiaryLog.fromJson(x))),
      );
}
