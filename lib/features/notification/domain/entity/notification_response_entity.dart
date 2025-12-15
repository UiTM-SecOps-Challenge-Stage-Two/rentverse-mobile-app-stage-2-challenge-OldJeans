class NotificationItemEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItemEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  NotificationItemEntity copyWith({bool? isRead}) {
    return NotificationItemEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationMetaEntity {
  final int limit;
  final int total;
  final String? nextCursor;
  final bool hasMore;

  const NotificationMetaEntity({
    required this.limit,
    required this.total,
    required this.nextCursor,
    required this.hasMore,
  });
}

class NotificationListEntity {
  final List<NotificationItemEntity> items;
  final NotificationMetaEntity meta;

  const NotificationListEntity({required this.items, required this.meta});
}
