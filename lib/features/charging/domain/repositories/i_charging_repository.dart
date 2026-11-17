import '../entities/charging_session_entity.dart';

abstract class IChargingRepository {
  Future<List<ChargingGunEntity>> getAvailableGuns(String stationId);
  Future<List<ChargingSessionEntity>> getChargingHistory();
  Future<void> saveCompletedSession(ChargingSessionEntity session);
  Stream<List<StationReviewEntity>> watchStationReviews(String stationId);
}