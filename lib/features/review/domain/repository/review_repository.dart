import 'package:rentverse/core/resources/data_state.dart';

abstract class ReviewRepository {
  Future<DataState<void>> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  });

  /// Returns raw response map containing data and meta for pagination
  Future<DataState<Map<String, dynamic>>> getPropertyReviews(
    String propertyId,
    int limit,
    String? cursor,
  );
}
