import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart'; // reuse the existing dioProvider
import '../data/datasource/analytics_datasource.dart';
import '../data/repository/analytics_repository.dart';
import '../data/models/analytics_model.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalyticsRepository(AnalyticsDatasource(dio));
});

/// FutureProvider automatically handles loading/error/data states for us —
/// the dashboard screen just watches this and reacts to whichever state it's in.
final ownerAnalyticsProvider = FutureProvider<OwnerAnalytics>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getOwnerAnalytics();
});