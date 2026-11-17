import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Stream<ProfileEntity> watchUserProfile();
  Future<List<SupportedEvEntity>> getSupportedEvModels();
  String getUserManualUrl();
}