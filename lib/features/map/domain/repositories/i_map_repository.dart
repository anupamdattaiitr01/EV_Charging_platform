import '../entities/station_location_entity.dart';

abstract class IMapRepository {
  Future<List<StationLocationEntity>> getNearbyStations();

  Future<RouteResultEntity> getTrafficRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}