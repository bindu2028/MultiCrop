import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_history_item.dart';
import 'api_service.dart';

class HistoryService {
  static const _historyKey = 'scan_history_v1';
  final ApiService _api = ApiService();

  Future<List<ScanHistoryItem>> loadHistory() async {
    try {
      final cloudData = await _api.fetchScanHistory();
      final List<ScanHistoryItem> history = cloudData.map<ScanHistoryItem>((x) {
        return ScanHistoryItem(
          crop: x['crop_name']?.toString() ?? '',
          disease: x['disease']?.toString() ?? '',
          confidence: (x['confidence'] as num?)?.toDouble() ?? 0.0,
          scannedAt: x['scanned_at'] != null
              ? DateTime.parse(x['scanned_at'].toString())
              : DateTime.now(),
          remedy: x['remedy']?.toString() ?? '',
          imageUrl: x['image_url']?.toString(),
        );
      }).toList();

      // Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _historyKey,
        jsonEncode(history.map((entry) => entry.toJson()).toList()),
      );

      return history;
    } catch (_) {
      // Offline fallback
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
  }

  Future<void> saveScan(ScanHistoryItem item) async {
    final local = await loadHistory();
    final updated = [item, ...local].take(200).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey,
      jsonEncode(updated.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> clearHistory() async {
    try {
      await _api.clearScanHistory();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
