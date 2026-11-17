import '../../domain/repositories/i_manager_repository.dart';
import '../../domain/entities/filter_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../datasources/manager_remote_datasource.dart';
import '../models/manager_filter_models.dart';
import '../models/analytics_model.dart';

class ManagerRepositoryImpl implements IManagerRepository {
  final ManagerRemoteDataSource remoteDataSource;

  ManagerRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RegionEntity>> getFilters() async {
    final data = await remoteDataSource.fetchFilters();
    final regionsList = data['taxonomy'] as List? ?? [];
    final regionModels = regionsList.map((i) => RegionModel.fromJson(i)).toList();

    return regionModels.map((region) => RegionEntity(
      id: region.id,
      name: region.title,
      stations: region.stations.map((station) => StationEntity(
        id: station.id,
        name: station.title,
        guns: station.guns.map((gun) => GunEntity(
          id: gun.id,
          type: gun.title,
          status: 'Active',
        )).toList(),
      )).toList(),
    )).toList();
  }

  @override
  Future<AnalyticsEntity> getAnalytics(String gunId) async {
    final data = await remoteDataSource.fetchAnalytics(gunId);
    final analyticsModel = GunAnalytics.fromJson(data);

    return AnalyticsEntity(
      gunId: gunId,
      totalSessions: analyticsModel.summary.totalCarsToday,
      totalKwToday: analyticsModel.summary.totalKwToday,
      totalRevenue: analyticsModel.summary.revenueToday,
      uptimePercentage: (analyticsModel.summary.hoursActiveToday / 24.0) * 100,
      dailyTrends: analyticsModel.dailyTrends
          .map((t) => TrendPointEntity(
        label: t.label,
        kwUsed: t.kwUsed,
        revenue: t.revenue,
      ))
          .toList(),
      monthlyTrends: analyticsModel.monthlyTrends
          .map((t) => TrendPointEntity(
        label: t.label,
        kwUsed: t.kwUsed,
        revenue: t.revenue,
      ))
          .toList(),
    );
  }
}