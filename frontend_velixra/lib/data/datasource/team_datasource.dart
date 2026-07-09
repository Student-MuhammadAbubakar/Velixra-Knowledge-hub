import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../models/team_model.dart';

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

// ... inside TeamDatasource class ...

  Future<List<ManagerListItem>> getManagers() async {
    try {
      final response = await dio.get("/team/managers");
      return (response.data as List).map((m) => ManagerListItem.fromJson(m)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> requestChange({
    required int managerId,
    int? documentId,
    required String message,
  }) async {
    try {
      final response = await dio.post("/team/request-change", data: {
        "manager_id": managerId,
        "document_id": documentId,
        "message": message,
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

  Future<void> acceptInvitation({
    required String token,
    required String name,
    required String password,
  }) async {
    try {
      await dio.post(ApiConstants.acceptInvitation, data: {
        "token": token,
        "name": name,
        "password": password,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
