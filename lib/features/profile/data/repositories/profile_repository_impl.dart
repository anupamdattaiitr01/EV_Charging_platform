import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Stream<ProfileEntity> watchUserProfile() {
    return remoteDataSource.streamCurrentUserProfile();
  }

  @override
  Future<List<SupportedEvEntity>> getSupportedEvModels() {
    return remoteDataSource.fetchSupportedEvModels();
  }

  @override
  String getUserManualUrl() {
    return remoteDataSource.fetchUserManualUrl();
  }
}