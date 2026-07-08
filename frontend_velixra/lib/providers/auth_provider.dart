import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/storage/token_storage.dart';
import '../data/datasource/auth_datasource.dart';
import '../data/repository/auth_repository.dart';

final dioProvider = Provider<Dio>((ref) => DioClient().dio);
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(AuthDatasource(dio), tokenStorage);
});

/// Holds login screen state: idle, loading, success, or error.
class AuthState {
  final bool isLoading;
  final String? error;
  AuthState({this.isLoading = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  AuthNotifier(this.repository) : super(AuthState());

  Future<String?> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final user = await repository.login(email, password);
      state = AuthState(isLoading: false);
      return user.role; // returned so the screen knows where to navigate
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});