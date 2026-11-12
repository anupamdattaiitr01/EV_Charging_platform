import '../entities/filter_entity.dart';
import '../entities/analytics_entity.dart';

abstract class IManagerRepository {
  Future<List<RegionEntity>> getFilters();
  Future<AnalyticsEntity> getAnalytics(String gunId);
}