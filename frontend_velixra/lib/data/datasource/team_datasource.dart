import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';

class TeamDatasource {
  final Dio dio;
  TeamDatasource(this.dio);

  Future<String> inviteManager(String email) async {
    try {
      final response = await dio.post(ApiConstants.inviteManager, data: {
        "email": email,
      });
      return response.data["message"] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> inviteEmployee(String email) async {
    try {
      final response = await dio.post(ApiConstants.inviteEmployee, data: {
        "email": email,
      });
      return response.data["message"] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}