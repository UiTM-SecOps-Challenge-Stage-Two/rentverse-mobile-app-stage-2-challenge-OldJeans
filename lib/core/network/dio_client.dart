import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/api_urls.dart';
import 'interceptors.dart';

class DioClient {
  late final Dio _dio;
  

  final Logger _logger;
  final SharedPreferences _sharedPreferences;

  DioClient(this._logger, this._sharedPreferences) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Tambahkan Interceptor kita
    _dio.interceptors.add(DioInterceptor(_logger, _sharedPreferences));
  }

  // Getter ini yang akan dipanggil oleh Service Locator atau Repository
  Dio get dio => _dio;
}
