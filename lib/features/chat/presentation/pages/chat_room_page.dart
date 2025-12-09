import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/chat/presentation/cubit/chat_room/chat_room_cubit.dart';
import 'package:rentverse/features/chat/presentation/cubit/chat_room_view/cubit.dart';
import 'package:rentverse/features/chat/presentation/pages/chat_room_page_view.dart';

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.otherUserName,
    required this.propertyTitle,
    required this.currentUserId,
    this.otherUserAvatar,
  });

  final String roomId;
  final String otherUserName;
  final String propertyTitle;
  final String currentUserId;
  final String? otherUserAvatar;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatRoomCubit(
            sl(),
            sl(),
            notificationService: sl(),
            currentUserId: currentUserId,
          )..init(roomId),
        ),
        BlocProvider(create: (_) => ChatRoomViewCubit()),
      ],
      child: ChatRoomView(
        otherUserName: otherUserName,
        propertyTitle: propertyTitle,
        otherUserAvatar: otherUserAvatar,
      ),
    );
  }
}
