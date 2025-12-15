import 'package:equatable/equatable.dart';
import 'package:rentverse/features/notification/domain/entity/notification_response_entity.dart';

class NotificationState extends Equatable {
  final List<NotificationItemEntity> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;
  final Set<String> markingIds;

  const NotificationState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
    this.markingIds = const {},
  });

  NotificationState copyWith({
    List<NotificationItemEntity>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? nextCursor,
    String? error,
    Set<String>? markingIds,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: error,
      markingIds: markingIds ?? this.markingIds,
    );
  }

  @override
  List<Object?> get props => [
    items,
    isLoading,
    isLoadingMore,
    hasMore,
    nextCursor,
    error,
    markingIds,
  ];
}
