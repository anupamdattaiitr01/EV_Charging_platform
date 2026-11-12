class RegionEntity {
  final String id;
  final String name;
  final List<StationEntity> stations;

  RegionEntity({required this.id, required this.name, required this.stations});
}

class StationEntity {
  final String id;
  final String name;
  final List<GunEntity> guns;

  StationEntity({required this.id, required this.name, required this.guns});
}

class GunEntity {
  final String id;
  final String type;
  final String status;

  GunEntity({required this.id, required this.type, required this.status});
}