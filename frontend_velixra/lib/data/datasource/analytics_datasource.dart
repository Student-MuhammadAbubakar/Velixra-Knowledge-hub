import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_exception.dart';
import '../models/analytics_model.dart';

class AnalyticsDatasource {
  final Dio dio;
  AnalyticsDatasource(this.dio);

  Future<OwnerAnalytics> getOwnerAnalytics() async {
    try {
      final response = await dio.get(ApiConstants.analytics);
      return OwnerAnalytics.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}