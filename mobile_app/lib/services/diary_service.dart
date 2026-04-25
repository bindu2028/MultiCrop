import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_model.dart';
import 'dart:math';

class DiaryService {
  static const String _key = 'plant_diary_v1';

  Future<List<PlantTracker>> getPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((x) => PlantTracker.fromJson(json.decode(x))).toList();
  }

  Future<void> savePlants(List<PlantTracker> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final data = plants.map((x) => json.encode(x.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> addPlant(String plantName, String crop) async {
    final plants = await getPlants();
    
    // Create an initial timeline event
    final newPlant = PlantTracker(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
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
  }
}
