import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/station_location_entity.dart';
import '../../domain/repositories/i_map_repository.dart';

class MapState {
  final double userLatitude;
  final double userLongitude;
  final List<StationLocationEntity> stations;
  final StationLocationEntity? selectedStation;
  final List<RouteCoordinateEntity> routePoints;
  final String? realTimeEta;
  final String? realTimeDistance;
  final bool isFetchingRoute;
  final String? errorMessage;

  const MapState({
    this.userLatitude = 28.435472,
    this.userLongitude = 77.082348,
    this.stations = const [],
    this.selectedStation,
    this.routePoints = const [],
    this.realTimeEta,
    this.realTimeDistance,
    this.isFetchingRoute = false,
    this.errorMessage,
  });

  MapState copyWith({
    double? userLatitude,
    double? userLongitude,
    List<StationLocationEntity>? stations,
    StationLocationEntity? selectedStation,
    bool clearSelectedStation = false,
    List<RouteCoordinateEntity>? routePoints,
    String? realTimeEta,
    String? realTimeDistance,
    bool? isFetchingRoute,
    String? errorMessage,
  }) {
    return MapState(
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      stations: stations ?? this.stations,
      selectedStation: clearSelectedStation ? null : (selectedStation ?? this.selectedStation),
      routePoints: routePoints ?? this.routePoints,
      realTimeEta: clearSelectedStation ? null : (realTimeEta ?? this.realTimeEta),
      realTimeDistance: clearSelectedStation ? null : (realTimeDistance ?? this.realTimeDistance),
      isFetchingRoute: isFetchingRoute ?? this.isFetchingRoute,
      errorMessage: errorMessage,
    );
  }
}

class MapCubit extends Cubit<MapState> {
  final IMapRepository _repository;

  MapCubit(this._repository) : super(const MapState());

  Future<void> loadStations() async {
    try {
      final stations = await _repository.getNearbyStations();
      emit(state.copyWith(stations: stations));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> selectStation(StationLocationEntity station) async {
    emit(state.copyWith(
      selectedStation: station,
      routePoints: const [],
      realTimeEta: 'Calculating...',
      realTimeDistance: '...',
      isFetchingRoute: true,
      errorMessage: null,
    ));

    try {
      final result = await _repository.getTrafficRoute(
        originLat: state.userLatitude,
        originLng: state.userLongitude,
        destLat: station.latitude,
        destLng: station.longitude,
      );

      if (result.isSuccess) {
        emit(state.copyWith(
          isFetchingRoute: false,
          routePoints: result.points,
          realTimeEta: result.etaText ?? station.eta,
          realTimeDistance: result.distanceText ?? station.distance,
        ));
      } else {
        emit(state.copyWith(
          isFetchingRoute: false,
          realTimeEta: 'Failed',
          realTimeDistance: 'Failed',
          errorMessage: result.errorMessage,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isFetchingRoute: false,
        realTimeEta: 'Failed',
        realTimeDistance: 'Failed',
        errorMessage: e.toString(),
      ));
    }
  }

  void findNearestStation() {
    if (state.stations.isEmpty) return;

    StationLocationEntity? nearest;
    double minDistance = double.infinity;

    for (final station in state.stations) {
      final dist = calculateDistanceKm(
        state.userLatitude,
        state.userLongitude,
        station.latitude,
        station.longitude,
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearest = station;
      }
    }

    if (nearest != null) {
      selectStation(nearest);
    }
  }

  void clearSelection() {
    emit(state.copyWith(
      clearSelectedStation: true,
      routePoints: const [],
      isFetchingRoute: false,
      errorMessage: null,
    ));
  }

  double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // math.pi / 180
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }
}