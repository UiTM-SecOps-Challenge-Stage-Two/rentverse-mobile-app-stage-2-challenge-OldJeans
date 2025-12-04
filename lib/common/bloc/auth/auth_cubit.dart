import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/bloc/auth/auth_state.dart';
import 'package:rentverse/core/services/service_locator.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AppInitialState());

  Future<void> checkAuthStatus() async {
    final bool isLoggedIn = await sl<IsLoggedInUseCase>().call(param: Void);
    if (isLoggedIn) {
      emit(Authenticated());
    } else {
      emit(UnAuthenticated());
    }
  }
}
