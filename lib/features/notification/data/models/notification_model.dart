import 'package:rentverse/features/notification/domain/entity/notification_response_entity.dart';

class NotificationMetaModel {
  final int limit;
  final int total;
  final String? nextCursor;
  final bool hasMore;

  const NotificationMetaModel({
    required this.limit,
    required this.total,
    required this.nextCursor,
    required this.hasMore,
  });

  factory NotificationMetaModel.fromJson(Map<String, dynamic> json) {
    return NotificationMetaModel(
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse('${json['limit']}') ?? 0,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse('${json['total']}') ?? 0,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] == true,
    );
  }

  NotificationMetaEntity toEntity() {
    return NotificationMetaEntity(
      limit: limit,
      total: total,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }
}

class NotificationItemModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItemModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      data: (json['data'] as Map?)?.map(
        (key, value) => MapEntry('$key', value),
      ),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  NotificationItemEntity toEntity() {
    return NotificationItemEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationListModel {
  final List<NotificationItemModel> items;
  final NotificationMetaModel meta;

  const NotificationListModel({required this.items, required this.meta});

  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    final meta = NotificationMetaModel.fromJson(json['meta'] ?? {});
    final itemsJson = json['data'] as List? ?? [];
    final items = itemsJson
        .whereType<Map<String, dynamic>>()
        .map(NotificationItemModel.fromJson)
        .toList();
    return NotificationListModel(items: items, meta: meta);
  }

  NotificationListEntity toEntity() {
    return NotificationListEntity(
      items: items.map((e) => e.toEntity()).toList(),
      meta: meta.toEntity(),
    );
  }
}
