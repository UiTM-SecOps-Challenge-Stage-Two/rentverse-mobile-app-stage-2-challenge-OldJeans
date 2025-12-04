// lib/common/bloc/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import '../../../features/auth/domain/entity/user_entity.dart'; // Pastikan path import ini benar

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AppInitialState extends AuthState {}

// UPDATE BAGIAN INI:
class Authenticated extends AuthState {
  final UserEntity user; // <--- Kantong untuk simpan data user

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user]; // Supaya Bloc tahu kalau user berubah
}

class UnAuthenticated extends AuthState {}

class FirstRun extends AuthState {}
