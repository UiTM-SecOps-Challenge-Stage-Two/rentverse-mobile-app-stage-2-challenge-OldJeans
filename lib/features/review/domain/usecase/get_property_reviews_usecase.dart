import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/usecase/usecase.dart';
import '../repository/review_repository.dart';

class GetPropertyReviewsParams {
  final String propertyId;
  final int limit;
  final String? cursor;
  GetPropertyReviewsParams({
    required this.propertyId,
    this.limit = 5,
    this.cursor,
  });
}

class GetPropertyReviewsUseCase
    implements
        UseCase<DataState<Map<String, dynamic>>, GetPropertyReviewsParams> {
  final ReviewRepository _repo;
  GetPropertyReviewsUseCase(this._repo);

  @override
  Future<DataState<Map<String, dynamic>>> call({
    GetPropertyReviewsParams? param,
  }) {
    if (param == null) throw ArgumentError('param required');
    return _repo.getPropertyReviews(
      param.propertyId,
      param.limit,
      param.cursor,
    );
  }
}
