import 'package:rentverse/core/network/dio_client.dart';
import 'package:rentverse/core/network/response/base_response_model.dart';

abstract class ReviewApiService {
  Future<BaseResponseModel<Map<String, dynamic>>> submitReview(
    Map<String, dynamic> body,
  );

  Future<BaseResponseModel<Map<String, dynamic>>> getPropertyReviews(
    String propertyId,
    int limit,
    String? cursor,
  );
}

class ReviewApiServiceImpl implements ReviewApiService {
  final DioClient _dioClient;
  ReviewApiServiceImpl(this._dioClient);

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> submitReview(
    Map<String, dynamic> body,
  ) async {
    final response = await _dioClient.post('/reviews', data: body);
    return BaseResponseModel.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> getPropertyReviews(
    String propertyId,
    int limit,
    String? cursor,
  ) async {
    final q = <String, dynamic>{'limit': limit};
    if (cursor != null) q['cursor'] = cursor;
    final response = await _dioClient.get(
      '/reviews/property/$propertyId',
      queryParameters: q,
    );
    return BaseResponseModel.fromJson(
      response.data,
      (json) =>
          {
                'items': json,
                'meta': response.data != null && response.data['meta'] != null
                    ? response.data['meta'] as Map<String, dynamic>
                    : <String, dynamic>{},
              }
              as Map<String, dynamic>,
    );
  }
}
