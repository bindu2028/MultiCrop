import 'package:flutter/material.dart';

import '../models/app_notification_item.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService.instance;
  late Future<List<AppNotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _service.markAllRead().then((_) => _service.loadInbox());
  }

  Future<void> _refresh() async {
    setState(() {
      _notificationsFuture = _service.loadInbox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await _service.clearInbox();
              await _refresh();
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
      body: FutureBuilder<List<AppNotificationItem>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? const [];
          if (notifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You will see scan results and app alerts here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF66736A)),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.read ? const Color(0xFFE9F2EA) : const Color(0xFFD8F0DE),
                      child: Icon(
                        item.read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                        color: const Color(0xFF2B7A3F),
                      ),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(item.body),
                    trailing: Text(
                      _formatTimestamp(item.createdAt),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C72)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}