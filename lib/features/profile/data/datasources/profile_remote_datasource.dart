import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile_model.dart';

class ProfileRemoteDataSource {
  Stream<ProfileModel> streamCurrentUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(
        ProfileModel.fromRealtimeMap(
          uid: '',
          fallbackPhone: '+91 XXXXXXXXXX',
          data: null,
        ),
      );
    }

    return FirebaseDatabase.instance
        .ref('users/${user.uid}')
        .onValue
        .map((DatabaseEvent event) {
      final raw = event.snapshot.value;
      final dataMap = raw is Map ? raw : null;
      return ProfileModel.fromRealtimeMap(
        uid: user.uid,
        fallbackPhone: user.phoneNumber ?? '+91 XXXXXXXXXX',
        data: dataMap,
      );
    });
  }

  Future<List<SupportedEvEntity>> fetchSupportedEvModels() async {
    await Future.delayed(const Duration(seconds: 2));

    return const [
      SupportedEvEntity(brand: 'Tata', model: 'Nexon EV', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Tata', model: 'Punch EV', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Tata', model: 'Tiago EV', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Tata', model: 'Curvv EV', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Mahindra', model: 'BE 6', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Mahindra', model: 'XEV 9e', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Mahindra', model: 'XUV400', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'MG', model: 'Windsor EV', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'MG', model: 'ZS EV', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'MG', model: 'Comet EV', connector: 'Type 2 AC'),
      SupportedEvEntity(brand: 'Maruti Suzuki', model: 'e Vitara', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Hyundai', model: 'Creta Electric', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Hyundai', model: 'Ioniq 5', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Kia', model: 'EV6', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'BYD', model: 'Atto 3', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'BYD', model: 'Seal', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'BMW', model: 'i4', connector: 'CCS2 & Type 2 AC'),
      SupportedEvEntity(brand: 'Mercedes-Benz', model: 'EQE', connector: 'CCS2 & Type 2 AC'),
    ];
  }

  String fetchUserManualUrl() {
    return 'https://coolors.co/';
  }
}