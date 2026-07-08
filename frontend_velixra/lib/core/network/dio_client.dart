import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

/// One shared Dio instance for the whole app — same "build once, reuse
/// everywhere" principle from your backend's database engine and
/// embedding model. An interceptor automatically attaches the saved JWT
/// to every outgoing request, so individual datasource calls never need
/// to manually handle auth headers themselves.
class DioClient {
  final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage();

  DioClient()
      : dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
      ),
    );
  }
}