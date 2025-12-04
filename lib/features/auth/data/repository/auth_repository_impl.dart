//lib/features/auth/data/repository/auth_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:rentverse/features/auth/data/source/auth_local_service.dart';

import '../../../../core/resources/data_state.dart';
import '../../domain/entity/login_request_entity.dart';
import '../../domain/entity/register_request_enity.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../models/request/login_request_model.dart';
import '../models/request/register_request_model.dart';
import '../source/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<DataState<UserEntity>> login(LoginRequestEntity params) async {
    try {
      // 1. Convert Entity -> Model
      final requestModel = LoginRequestModel.fromEntity(params);

      // 2. Panggil API (Return: LoginResponseModel yang punya token & user)
      final httpResponse = await _apiService.login(requestModel);

      if (httpResponse.data != null) {
        final loginData = httpResponse.data!;

        // 3. LOGIC PENTING: Simpan Token dan User secara terpisah
        // Simpan Token (untuk Interceptor)
        await _localDataSource.saveToken(loginData.token);

        // Simpan User Profile (untuk UI/Role)
        await _localDataSource.saveUser(loginData.user);

        // 4. Return User Entity bersih ke Domain
        return DataSuccess(data: loginData.user);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            error: httpResponse.message ?? 'Login data is empty',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> register(RegisterRequestEntity params) async {
    try {
      final requestModel = RegisterRequestModel.fromEntity(params);

      // Register biasanya return UserModel saja (tanpa token, kecuali auto-login)
      final httpResponse = await _apiService.register(requestModel);

      if (httpResponse.data != null) {
        // Simpan data user terbaru (tanpa token, karena belum login)
        // Atau jika backend auto-login, sesuaikan logicnya seperti login di atas
        await _localDataSource.saveUser(httpResponse.data!);

        return DataSuccess(data: httpResponse.data!);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/register'),
            error: httpResponse.message ?? 'Register data is empty',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> getUserProfile() async {
    try {
      final httpResponse = await _apiService.getProfile();

      if (httpResponse.data != null) {
        // Selalu update cache user saat berhasil fetch profile terbaru
        await _localDataSource.saveUser(httpResponse.data!);
        return DataSuccess(data: httpResponse.data!);
      } else {
        return DataFailed(
          DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            error: httpResponse.message ?? 'User Profile not found',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<void> logout() async {
    // Bersihkan semua data sesi lokal
    await _localDataSource.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    // Cek ke local data source apakah token/user ada
    return _localDataSource.isLoggedIn();
  }

  @override
  Future<UserEntity?> getLastLocalUser() async {
    return _localDataSource
        .getLastUser(); // Panggil local data source yg kita buat tadi
  }
}
