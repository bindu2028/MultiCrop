import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_model.dart';
import 'api_service.dart';
import 'dart:math';

class DiaryService {
  static const String _key = 'plant_diary_v1';
  final ApiService _api = ApiService();

  Future<List<PlantTracker>> getPlants() async {
    try {
      final cloudData = await _api.fetchTrackedPlants();
      final parsed = cloudData.map((x) {
        List<DiaryLog> logsList = [];
        if (x['notes'] != null && x['notes'].toString().isNotEmpty) {
          try {
            final decodedLogs = jsonDecode(x['notes'].toString());
            if (decodedLogs is List) {
              logsList = decodedLogs
                  .map((logJson) => DiaryLog.fromJson(logJson))
                  .toList();
            }
          } catch (_) {}
        }

        if (logsList.isEmpty) {
          logsList = [
            DiaryLog(
              id: 'init_${x['id']}',
              date: x['created_at'] != null 
                  ? DateTime.parse(x['created_at'].toString()) 
                  : DateTime.now(),
              note: 'Started tracking ${x['plant_name']}',
              actionType: 'Started',
            )
          ];
        }

        return PlantTracker(
          id: x['id']?.toString() ?? '',
          plantName: x['plant_name']?.toString() ?? '',
          crop: x['crop_type']?.toString() ?? '',
          dateAdded: x['created_at'] != null 
              ? DateTime.parse(x['created_at'].toString()) 
              : DateTime.now(),
          logs: logsList,
        );
      }).toList();

      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      final data = parsed.map((x) => json.encode(x.toJson())).toList();
      await prefs.setStringList(_key, data);

      return parsed;
    } catch (_) {
      // Offline fallback
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_key) ?? [];
      return data.map((x) => PlantTracker.fromJson(json.decode(x))).toList();
    }
  }

  Future<void> savePlants(List<PlantTracker> plants) async {
    // Save locally
    final prefs = await SharedPreferences.getInstance();
    final data = plants.map((x) => json.encode(x.toJson())).toList();
    await prefs.setStringList(_key, data);

    // Sync each plant to the backend API
    for (final plant in plants) {
      try {
        final payload = {
          'id': int.tryParse(plant.id),
          'plant_name': plant.plantName,
          'crop_type': plant.crop,
          'status': 'healthy',
          'notes': jsonEncode(plant.logs.map((log) => log.toJson()).toList()),
        };
        await _api.addOrUpdateTrackedPlant(payload);
      } catch (_) {
        // Continue optimistically if single sync fails
      }
    }
  }

  Future<void> addPlant(String plantName, String crop) async {
    final plants = await getPlants();
    
    // Create an initial timeline event
    final newPlant = PlantTracker(
      id: (DateTime.now().millisecondsSinceEpoch % 1000000).toString() + Random().nextInt(100).toString(),
      plantName: plantName,
      crop: crop,
      dateAdded: DateTime.now(),
      logs: [
        DiaryLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          note: 'Started tracking $plantName',
          actionType: 'Started',
        )
      ]
    );

    plants.add(newPlant);
    await savePlants(plants);
  }

  Future<void> addLogToPlant(String plantId, DiaryLog log) async {
    final plants = await getPlants();
    final index = plants.indexWhere((p) => p.id == plantId);
    if (index >= 0) {
      final plant = plants[index];
      final updatedLogs = List<DiaryLog>.from(plant.logs)..insert(0, log); // Add newest at top
      
      // Keep sort order descending
      updatedLogs.sort((a, b) => b.date.compareTo(a.date));

      final updatedPlant = PlantTracker(
        id: plant.id,
        plantName: plant.plantName,
        crop: plant.crop,
        dateAdded: plant.dateAdded,
        logs: updatedLogs,
      );
      
      plants[index] = updatedPlant;
      await savePlants(plants);
    }
  }

  Future<void> deletePlant(String plantId) async {
    final plants = await getPlants();
    plants.removeWhere((p) => p.id == plantId);
    await savePlants(plants);

    final intId = int.tryParse(plantId);
    if (intId != null) {
      try {
        await _api.deleteTrackedPlant(intId);
      } catch (_) {}
    }
  }
}
