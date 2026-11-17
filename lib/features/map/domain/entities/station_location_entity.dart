class StationLocationEntity {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String eta;
  final String distance;
  final String routeName;
  final String power;
  final String price;
  final double markerHue;

  const StationLocationEntity({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.eta,
    required this.distance,
    required this.routeName,
    required this.power,
    required this.price,
    required this.markerHue,
  });
}

class RouteCoordinateEntity {
  final double latitude;
  final double longitude;

  const RouteCoordinateEntity({
    required this.latitude,
    required this.longitude,
  });
}

class RouteResultEntity {
  final List<RouteCoordinateEntity> points;
  final String? etaText;
  final String? distanceText;
  final String? errorMessage;

  const RouteResultEntity({
    this.points = const [],
    this.etaText,
    this.distanceText,
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null && points.isNotEmpty;
}