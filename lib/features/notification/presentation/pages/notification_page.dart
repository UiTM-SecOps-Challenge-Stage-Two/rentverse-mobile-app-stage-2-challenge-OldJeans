import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/notification/domain/entity/notification_response_entity.dart';
import 'package:rentverse/features/notification/domain/usecase/get_notifications_usecase.dart';
import 'package:rentverse/features/notification/domain/usecase/mark_notification_read_usecase.dart';
import 'package:rentverse/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:rentverse/features/notification/presentation/cubit/notification_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(
        sl<GetNotificationsUseCase>(),
        sl<MarkNotificationReadUseCase>(),
      )..load(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'), centerTitle: true),
      body: const _NotificationBody(),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  const _NotificationBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tidak bisa memuat notifikasi: ${state.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<NotificationCubit>().load(),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<NotificationCubit>().load(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('Belum ada notifikasi.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<NotificationCubit>().load(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 120 &&
                  scroll is ScrollUpdateNotification) {
                context.read<NotificationCubit>().loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final item = state.items[index];
                final isMarking = state.markingIds.contains(item.id);
                return _NotificationTile(
                  item: item,
                  isMarking: isMarking,
                  onTap: () =>
                      context.read<NotificationCubit>().markRead(item.id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.isMarking,
    required this.onTap,
  });

  final NotificationItemEntity item;
  final bool isMarking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final createdText = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(item.createdAt.toLocal());
    final bgColor = item.isRead ? Colors.white : Colors.blue.shade50;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4, right: 10),
                decoration: BoxDecoration(
                  color: item.isRead ? Colors.transparent : Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.type,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          createdText,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isMarking)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
