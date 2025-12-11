import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/usecase/usecase.dart';
import '../repository/review_repository.dart';

class SubmitReviewParams {
  final String bookingId;
  final int rating;
  final String? comment;

  SubmitReviewParams({
    required this.bookingId,
    required this.rating,
    this.comment,
  });
}

class SubmitReviewUseCase
    implements UseCase<DataState<void>, SubmitReviewParams> {
  final ReviewRepository _repo;
  SubmitReviewUseCase(this._repo);

  @override
  Future<DataState<void>> call({SubmitReviewParams? param}) {
    if (param == null) throw ArgumentError('param required');
    return _repo.submitReview(
      bookingId: param.bookingId,
      rating: param.rating,
      comment: param.comment,
    );
  }
}
