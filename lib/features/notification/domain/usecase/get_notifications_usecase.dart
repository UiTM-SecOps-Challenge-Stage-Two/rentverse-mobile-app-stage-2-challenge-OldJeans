import 'package:rentverse/core/usecase/usecase.dart';
import 'package:rentverse/features/notification/domain/entity/notification_response_entity.dart';
import 'package:rentverse/features/notification/domain/repository/notification_repository.dart';

class GetNotificationsParams {
  final int limit;
  final String? cursor;

  const GetNotificationsParams({this.limit = 20, this.cursor});
}

class GetNotificationsUseCase
    implements UseCase<NotificationListEntity, GetNotificationsParams> {
  GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<NotificationListEntity> call({GetNotificationsParams? param}) {
    final p = param ?? const GetNotificationsParams();
    return _repository.getNotifications(limit: p.limit, cursor: p.cursor);
  }
}
