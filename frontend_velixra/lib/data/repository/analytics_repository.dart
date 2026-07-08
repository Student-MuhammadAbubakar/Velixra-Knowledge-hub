import '../datasource/analytics_datasource.dart';
import '../models/analytics_model.dart';

class AnalyticsRepository {
  final AnalyticsDatasource datasource;
  AnalyticsRepository(this.datasource);

  Future<OwnerAnalytics> getOwnerAnalytics() => datasource.getOwnerAnalytics();
}