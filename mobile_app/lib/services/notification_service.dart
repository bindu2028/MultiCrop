import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_notification_item.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const MethodChannel _channel = MethodChannel('plantlens_notifications');
  static const _inboxKey = 'app_notifications_v1';
  static const _followUpsEnabledKey = 'follow_up_reminders_enabled_v1';
  static const _appUpdatesEnabledKey = 'app_updates_enabled_v1';

  Future<void> initialize() async {
    try {
      await _channel.invokeMethod<bool>('initialize');
    } catch (_) {
      // Native notifications are best-effort. The app still works if the user
      // denies permission or the device blocks alerts.
    }
  }

  Future<void> showPredictionNotification({
    required String crop,
    required String disease,
    required double confidence,
    required bool isUncertain,
  }) async {
    final confidencePercent = (confidence * 100).clamp(0, 100).toStringAsFixed(1);
    final title = isUncertain ? 'Scan needs another look' : 'Scan complete for ${_formatCrop(crop)}';
    final body = isUncertain
        ? 'Low confidence result: ${_formatDisease(disease)} at $confidencePercent%. Try a clearer leaf photo.'
        : '${_formatDisease(disease)} detected with $confidencePercent% confidence.';

    try {
      await _channel.invokeMethod<void>(
        'showPrediction',
        {
          'title': title,
          'body': body,
        },
      );
    } catch (_) {
      // Ignore notification delivery failures and still store the inbox entry.
    }

    await _storeInboxItem(
      AppNotificationItem(
        title: title,
        body: body,
        createdAt: DateTime.now(),
        read: false,
      ),
    );
  }

  Future<void> scheduleFollowUpReminder({
    required String crop,
    required String disease,
    required int daysLater,
  }) async {
    final isEnabled = await followUpRemindersEnabled();
    if (!isEnabled) {
      return;
    }

    final scheduleTime = DateTime.now().add(Duration(days: daysLater));
    final title = 'Follow-up scan for ${_formatCrop(crop)}';
    final body = 'Recheck ${_formatDisease(disease)} and capture a new leaf scan today.';

    try {
      await _channel.invokeMethod<void>(
        'scheduleFollowUp',
        {
          'title': title,
          'body': body,
          'timestampMs': scheduleTime.millisecondsSinceEpoch,
        },
      );
    } catch (_) {
      // Scheduling can fail on some OEM devices; keep app flow uninterrupted.
    }

    await _storeInboxItem(
      AppNotificationItem(
        title: 'Reminder scheduled',
        body: 'We will remind you in $daysLater days to recheck ${_formatCrop(crop)}.',
        createdAt: DateTime.now(),
        read: false,
      ),
    );
  }

  Future<bool> followUpRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_followUpsEnabledKey) ?? true;
  }

  Future<bool> appUpdatesEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appUpdatesEnabledKey) ?? true;
  }

  Future<void> setNotificationPreferences({
    required bool followUpsEnabled,
    required bool appUpdatesEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followUpsEnabledKey, followUpsEnabled);
    await prefs.setBool(_appUpdatesEnabledKey, appUpdatesEnabled);
  }

  Future<List<AppNotificationItem>> loadInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_inboxKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    final notifications = decoded
        .whereType<Map<String, dynamic>>()
        .map(AppNotificationItem.fromJson)
        .toList();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  Future<int> unreadCount() async {
    final inbox = await loadInbox();
    return inbox.where((item) => !item.read).length;
  }

  Future<void> markAllRead() async {
    final updated = (await loadInbox())
        .map((item) => item.copyWith(read: true))
        .toList();
    await _saveInbox(updated);
  }

  Future<void> clearInbox() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_inboxKey);
  }

  Future<void> _storeInboxItem(AppNotificationItem item) async {
    final updated = [item, ...(await loadInbox())].take(100).toList();
    await _saveInbox(updated);
  }

  Future<void> _saveInbox(List<AppNotificationItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _inboxKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  String _formatCrop(String crop) {
    return crop.replaceAll('_', ' ').trim();
  }

  String _formatDisease(String disease) {
    return disease.replaceAll('_', ' ').trim();
  }
}