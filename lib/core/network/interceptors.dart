import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/api_urls.dart'; // Pastikan path ini sesuai dengan file ApiConstants kamu

class DioInterceptor extends Interceptor {
  final Logger _logger;
  final SharedPreferences _sharedPreferences;

  DioInterceptor(this._logger, this._sharedPreferences);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Log Request Keluar
    _logger.i('--> ${options.method.toUpperCase()} ${options.uri}');
    _logger.t('Headers: ${options.headers}');
    _logger.t('Body: ${options.data}');

    // 2. Ambil Token dari Shared Preferences
    final token = _sharedPreferences.getString(ApiConstants.tokenKey);

    // 3. Jika token ada, sisipkan ke Header Authorization
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjut ke request server
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 1. Log Response Sukses
    _logger.d('<-- ${response.statusCode} ${response.requestOptions.uri}');
    _logger.t('Data: ${response.data}');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 1. Log Error
    _logger.e('<-- ${err.response?.statusCode} ${err.requestOptions.uri}');
    _logger.e('Message: ${err.message}');
    _logger.e('Error Data: ${err.response?.data}');

    super.onError(err, handler);
  }
}
