import '../../domain/entities/charging_session_entity.dart';
import '../../domain/repositories/i_charging_repository.dart';
import '../datasources/charging_remote_datasource.dart';
import '../models/charging_session_model.dart';

class ChargingRepositoryImpl implements IChargingRepository {
  final ChargingRemoteDataSource remoteDataSource;

  ChargingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChargingGunEntity>> getAvailableGuns(String stationId) {
    return remoteDataSource.fetchGuns(stationId);
  }

  @override
  Future<List<ChargingSessionEntity>> getChargingHistory() {
    return remoteDataSource.fetchHistory();
  }

  @override
  Future<void> saveCompletedSession(ChargingSessionEntity session) {
    final model = ChargingSessionModel.fromEntity(session);
    return remoteDataSource.insertSession(model);
  }

  @override
  Stream<List<StationReviewEntity>> watchStationReviews(String stationId) {
    return remoteDataSource.streamReviews(stationId);
  }
}