// lib/features/manager/models/manager_filter_models.dart

class GunModel {
  final String id;
  final String title;

  GunModel({required this.id, required this.title});

  factory GunModel.fromJson(Map<String, dynamic> json) {
    return GunModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class StationModel {
  final String id;
  final String title;
  final List<GunModel> guns;

  StationModel({required this.id, required this.title, required this.guns});

  factory StationModel.fromJson(Map<String, dynamic> json) {
    // Look for the nested 'sub_items' array (the guns)
    var gunList = json['sub_items'] as List? ?? [];
    List<GunModel> parsedGuns = gunList.map((i) => GunModel.fromJson(i)).toList();

    return StationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      guns: parsedGuns,
    );
  }
}

class RegionModel {
  final String id;
  final String title;
  final List<StationModel> stations;

  RegionModel({required this.id, required this.title, required this.stations});

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    // Look for the nested 'sub_items' array (the stations)
    var stationList = json['sub_items'] as List? ?? [];
    List<StationModel> parsedStations = stationList.map((i) => StationModel.fromJson(i)).toList();

    return RegionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      stations: parsedStations,
    );
  }
}