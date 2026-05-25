import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/growth_diary_entry.dart';
import 'api_service.dart';

class GrowthDiaryService {
  static const _diaryKey = 'growth_diary_v1';
  final ApiService _api = ApiService();

  Future<List<GrowthDiaryEntry>> loadEntries() async {
    try {
      final cloudData = await _api.fetchTrackedPlants();
      final diaryPlants = cloudData.where((x) => x['status'] == 'diary_entry').toList();

      final parsed = diaryPlants.map((x) {
        String obs = '';
        String? img;
        if (x['notes'] != null && x['notes'].toString().isNotEmpty) {
          try {
            final decoded = jsonDecode(x['notes'].toString());
            if (decoded is Map<String, dynamic>) {
              obs = decoded['observation']?.toString() ?? '';
              img = decoded['imageBase64']?.toString();
            } else {
              obs = x['notes'].toString();
            }
          } catch (_) {
            obs = x['notes'].toString();
          }
        }

        return GrowthDiaryEntry(
          id: x['id']?.toString() ?? '',
          crop: x['crop_type']?.toString() ?? '',
          observation: obs,
          disease: x['last_disease']?.toString(),
          imageBase64: img,
          createdAt: x['created_at'] != null 
              ? DateTime.parse(x['created_at'].toString()) 
              : DateTime.now(),
        );
      }).toList();

      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _diaryKey,
        jsonEncode(parsed.map((e) => e.toJson()).toList()),
      );

      return parsed;
    } catch (_) {
      // Offline fallback
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_diaryKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      final entries = decoded
          .whereType<Map<String, dynamic>>()
          .map(GrowthDiaryEntry.fromJson)
          .toList();
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    }
  }

  Future<void> addEntry(GrowthDiaryEntry entry) async {
    // Save locally
    final current = await loadEntries();
    final updated = [entry, ...current].take(300).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _diaryKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );

    // Sync to backend
    try {
      final payload = {
        'id': int.tryParse(entry.id),
        'plant_name': 'Observation ${entry.crop}',
        'crop_type': entry.crop,
        'status': 'diary_entry',
        'last_disease': entry.disease,
        'notes': jsonEncode({
          'observation': entry.observation,
          'imageBase64': entry.imageBase64,
        }),
      };
      await _api.addOrUpdateTrackedPlant(payload);
    } catch (_) {}
  }

  Future<void> clearEntries() async {
    try {
      final entries = await loadEntries();
      for (final entry in entries) {
        final intId = int.tryParse(entry.id);
        if (intId != null) {
          await _api.deleteTrackedPlant(intId);
        }
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_diaryKey);
  }
}
