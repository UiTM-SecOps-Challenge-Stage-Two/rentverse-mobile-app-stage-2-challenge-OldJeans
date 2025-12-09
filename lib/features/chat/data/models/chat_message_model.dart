import 'package:rentverse/features/chat/domain/entity/chat_message_entity.dart';

class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return ChatMessageModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      roomId: (data['roomId'] ?? data['room_id'] ?? '').toString(),
      senderId:
          (data['senderId'] ?? data['sender_id'] ?? data['sender']?['id'] ?? '')
              .toString(),
      content: (data['content'] ?? data['message'] ?? data['body'] ?? '')
          .toString(),
      isRead: data['isRead'] == true || data['is_read'] == true,
      createdAt: _parseDate(data['createdAt'] ?? data['created_at']),
    );
  }

  ChatMessageEntity toEntity({required String currentUserId}) {
    return ChatMessageEntity(
      id: id,
      roomId: roomId,
      senderId: senderId,
      content: content,
      isRead: isRead,
      createdAt: createdAt,
      isMe: senderId == currentUserId,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}
