import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/growth_diary_entry.dart';

class GrowthDiaryService {
  static const _diaryKey = 'growth_diary_v1';

  Future<List<GrowthDiaryEntry>> loadEntries() async {
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

  Future<void> addEntry(GrowthDiaryEntry entry) async {
    final current = await loadEntries();
    final updated = [entry, ...current].take(300).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _diaryKey,
      jsonEncode(updated.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> clearEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_diaryKey);
  }
}
