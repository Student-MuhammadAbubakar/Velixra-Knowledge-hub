import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';

/// The ONLY file allowed to make raw HTTP calls for auth — exactly the
/// same discipline as your backend's repository layer only touching SQL.
class AuthDatasource {
  final Dio dio;
  AuthDatasource(this.dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(ApiConstants.login, data: {
        "email": email,
        "password": password,
      });
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await dio.post(ApiConstants.forgotPassword, data: {"email": email});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await dio.get("/auth/me");
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);}}
}

