import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/features/chat/data/models/chat_message_model.dart';
import 'package:rentverse/features/chat/data/source/chat_socket_service.dart';
import 'package:rentverse/features/chat/domain/entity/chat_message_entity.dart';
import 'package:rentverse/features/chat/domain/usecase/get_messages_usecase.dart';
import 'package:rentverse/features/chat/presentation/cubit/chat_room/chat_room_state.dart';
import 'package:rentverse/core/services/notification_service.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  ChatRoomCubit(
    this._getMessagesUseCase,
    this._socketService, {
    NotificationService? notificationService,
    required this.currentUserId,
  }) : _notificationService = notificationService,
       super(const ChatRoomState());

  final GetMessagesUseCase _getMessagesUseCase;
  // ignore: unused_field
  // HTTP send currently unused; messages are sent via socket
  final ChatSocketService _socketService;
  final NotificationService? _notificationService;
  final String currentUserId;

  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  Future<void> init(String roomId) async {
    emit(
      state.copyWith(
        status: ChatRoomStatus.loading,
        roomId: roomId,
        error: null,
      ),
    );

    _socketService.connect();
    _socketService.joinRoom(roomId);
    _listenSocket(roomId);
    _listenNotifications(roomId);

    await _loadMessages(roomId);
  }

  Future<void> _loadMessages(String roomId) async {
    try {
      final messages = await _getMessagesUseCase(
        roomId,
        currentUserId: currentUserId,
      );
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(
        state.copyWith(
          status: ChatRoomStatus.success,
          messages: messages,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatRoomStatus.failure, error: e.toString()));
    }
  }

  void _listenSocket(String roomId) {
    _socketSubscription?.cancel();
    _socketSubscription = _socketService.messageStream.listen((raw) {
      try {
        // Debug: trace every incoming payload for this room
        // ignore: avoid_print
        print('CHAT_ROOM SOCKET RAW room=$roomId payload=$raw');

        // The socket emits a Map payload. Some backends wrap the useful
        // message(s) under the `data` key and that value can be either a
        // single map or a list of maps. Normalize to a list of raw maps.
        final raws = <Map<String, dynamic>>[];
        final payload = raw['data'] ?? raw;
        if (payload is List) {
          for (final r in payload) {
            if (r is Map<String, dynamic>)
              raws.add(Map<String, dynamic>.from(r));
          }
        } else if (payload is Map<String, dynamic>) {
          raws.add(Map<String, dynamic>.from(payload));
        }

        var added = false;
        final current = [...state.messages];

        for (final r in raws) {
          try {
            final model = ChatMessageModel.fromJson(r);
            final message = model.toEntity(currentUserId: currentUserId);
            if (message.roomId != roomId) continue;

            // Deduplicate by id to avoid duplicates from optimistic updates
            final exists = current.any((m) => m.id == message.id);
            if (exists) continue;

            current.add(message);
            added = true;
            // ignore: avoid_print
            print(
              'CHAT_ROOM NEW_MESSAGE room=${message.roomId} id=${message.id} content=${message.content} at=${message.createdAt.toIso8601String()}',
            );
          } catch (_) {
            // ignore malformed entry
          }
        }

        if (added) {
          current.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          emit(
            state.copyWith(messages: current, status: ChatRoomStatus.success),
          );
        }
      } catch (_) {}
    });
  }

  Future<void> sendMessage(String content) async {
    final roomId = state.roomId;
    if (roomId == null || content.trim().isEmpty) return;

    emit(state.copyWith(sending: true, error: null));

    // Optimistic UI update so the message appears immediately
    final optimistic = ChatMessageEntity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      roomId: roomId,
      senderId: currentUserId,
      content: content,
      isRead: true,
      createdAt: DateTime.now(),
      isMe: true,
    );
    final updated = [...state.messages, optimistic]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    emit(state.copyWith(messages: updated, status: ChatRoomStatus.success));

    try {
      // Send via WebSocket only (backend expects socket event, not HTTP CRUD)
      _socketService.sendMessage(roomId, content);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    } finally {
      emit(state.copyWith(sending: false));
    }
  }

  @override
  Future<void> close() {
    if (state.roomId != null) {
      _socketService.leaveRoom(state.roomId!);
    }
    _socketSubscription?.cancel();
    _notificationSubscription?.cancel();
    return super.close();
  }

  void _listenNotifications(String roomId) {
    final notifier = _notificationService;
    if (notifier == null) return;
    _notificationSubscription?.cancel();
    _notificationSubscription = notifier.chatMessageStream.listen((data) {
      try {
        final model = ChatMessageModel.fromJson(data);
        final message = model.toEntity(currentUserId: currentUserId);
        if (message.roomId != roomId) return;

        final current = [...state.messages];
        final exists = current.any((m) => m.id == message.id);
        if (exists) return;

        current.add(message);
        current.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        // ignore: avoid_print
        print(
          'CHAT_ROOM NOTIF NEW_MESSAGE room=${message.roomId} id=${message.id} content=${message.content} at=${message.createdAt.toIso8601String()}',
        );
        emit(state.copyWith(messages: current, status: ChatRoomStatus.success));
      } catch (_) {
        // ignore parse errors
      }
    });
  }
}
