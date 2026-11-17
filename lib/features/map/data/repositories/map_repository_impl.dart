import '../../domain/entities/station_location_entity.dart';
import '../../domain/repositories/i_map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements IMapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StationLocationEntity>> getNearbyStations() {
    return remoteDataSource.fetchStations();
  }

  @override
  Future<RouteResultEntity> getTrafficRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    return remoteDataSource.fetchTrafficRoute(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
    );
  }
}