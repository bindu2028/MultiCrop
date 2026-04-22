class AppNotificationItem {
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  const AppNotificationItem({
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      title: (json['title'] ?? 'Notification').toString(),
      body: (json['body'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'read': read,
    };
  }

  AppNotificationItem copyWith({
    String? title,
    String? body,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotificationItem(
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}