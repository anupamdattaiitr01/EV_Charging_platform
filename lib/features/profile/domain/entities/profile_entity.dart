class SavedVehicleEntity {
  final String brand;
  final String model;
  final String connector;

  const SavedVehicleEntity({
    required this.brand,
    required this.model,
    required this.connector,
  });

  String get fullName => '$brand $model'.trim();
}

class ProfileEntity {
  final String uid;
  final String name;
  final String phone;
  final String dlNumber;
  final String address;
  final SavedVehicleEntity? primaryVehicle;
  final Map<String, dynamic> rawData;

  const ProfileEntity({
    required this.uid,
    required this.name,
    required this.phone,
    this.dlNumber = '',
    this.address = '',
    this.primaryVehicle,
    this.rawData = const {},
  });

  String get initial => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
}

class SupportedEvEntity {
  final String brand;
  final String model;
  final String connector;

  const SupportedEvEntity({
    required this.brand,
    required this.model,
    required this.connector,
  });

  String get displayName => '$brand $model';
}