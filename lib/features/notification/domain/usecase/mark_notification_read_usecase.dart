import 'package:rentverse/core/usecase/usecase.dart';
import 'package:rentverse/features/notification/domain/repository/notification_repository.dart';

class MarkNotificationReadUseCase implements UseCase<void, String> {
  MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<void> call({String? param}) {
    final id = param;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Notification id is required');
    }
    return _repository.markAsRead(id);
  }
}
