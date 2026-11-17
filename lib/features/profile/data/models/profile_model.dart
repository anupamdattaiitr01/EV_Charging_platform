import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.name,
    required super.phone,
    super.dlNumber,
    super.address,
    super.primaryVehicle,
    super.rawData,
  });

  factory ProfileModel.fromRealtimeMap({
    required String uid,
    required String fallbackPhone,
    Map<dynamic, dynamic>? data,
  }) {
    final normalizedMap = data != null
        ? data.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    final vehicleBrand = normalizedMap['vehicle_brand']?.toString() ?? 'TATA';
    final vehicleModel = normalizedMap['vehicle_model']?.toString() ?? 'Nexon EV';
    final vehicleConnector = normalizedMap['connector']?.toString() ?? 'CCS2';

    return ProfileModel(
      uid: uid,
      name: normalizedMap['name']?.toString() ?? 'User Name',
      phone: normalizedMap['phone']?.toString() ??
          (fallbackPhone.isNotEmpty ? fallbackPhone : '+91 XXXXXXXXXX'),
      dlNumber: normalizedMap['dl_number']?.toString() ?? '',
      address: normalizedMap['address']?.toString() ?? '',
      primaryVehicle: SavedVehicleEntity(
        brand: vehicleBrand,
        model: vehicleModel,
        connector: vehicleConnector,
      ),
      rawData: normalizedMap,
    );
  }
}