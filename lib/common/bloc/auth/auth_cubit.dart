// lib/common/bloc/auth/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/auth/domain/usecase/get_local_user_usecase.dart';
import 'package:rentverse/features/auth/domain/usecase/is_logged_in_usecase.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AppInitialState());
  Future<void> checkAuthStatus() async {
    try {
      final bool hasToken = await sl<IsLoggedInUsecase>().call();

      if (hasToken) {
        final user = await sl<GetLocalUserUseCase>().call();

        if (user != null) {
          emit(Authenticated(user: user)); 
        } else {
          emit(UnAuthenticated());
        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(UnAuthenticated());
    }
  }
}
