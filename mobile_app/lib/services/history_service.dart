import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_history_item.dart';

class HistoryService {
  static const _historyKey = 'scan_history_v1';

  Future<List<ScanHistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final history = decoded
        .whereType<Map<String, dynamic>>()
        .map(ScanHistoryItem.fromJson)
        .toList();

    history.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return history;
  }

  Future<void> saveScan(ScanHistoryItem item) async {
    final history = await loadHistory();
    final updated = [item, ...history].take(200).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(updated.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
