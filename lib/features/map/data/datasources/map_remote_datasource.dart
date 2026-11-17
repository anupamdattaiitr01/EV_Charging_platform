import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/station_location_entity.dart';

class MapRemoteDataSource {
  String get _googleApiKey => dotenv.env['MAPS_API_KEY'] ?? '';

  Future<List<StationLocationEntity>> fetchStations() async {
    return [
      StationLocationEntity(
        id: '1',
        name: 'Ardee City Fast Charger',
        latitude: 28.4380,
        longitude: 77.0800,
        eta: '4 Min',
        distance: '1.2 Km',
        routeName: 'Fastest Route Via Ardee Marg',
        power: '60kW DC Fast',
        price: '₹18 / KWh',
        markerHue: BitmapDescriptor.hueGreen,
      ),
      StationLocationEntity(
        id: '2',
        name: 'Wazirabad Hub',
        latitude: 28.4320,
        longitude: 77.0850,
        eta: '3 Min',
        distance: '0.8 Km',
        routeName: 'Fastest Route Via Main Rd',
        power: '120kW DC Ultra Fast',
        price: '₹22 / KWh',
        markerHue: BitmapDescriptor.hueOrange,
      ),
      StationLocationEntity(
        id: '3',
        name: 'Sector 52 Plaza',
        latitude: 28.4360,
        longitude: 77.0750,
        eta: '6 Min',
        distance: '1.5 Km',
        routeName: 'Fastest Route Via Sector Rd',
        power: '30kW AC Slow',
        price: '₹15 / KWh',
        markerHue: BitmapDescriptor.hueRed,
      ),
    ];
  }

  Future<RouteResultEntity> fetchTrafficRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final polylinePoints = PolylinePoints(apiKey: _googleApiKey);

    final RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(originLat, originLng),
        destination: PointLatLng(destLat, destLng),
        travelMode: TravelMode.driving,
        routingPreference: RoutingPreference.trafficAware,
      ),
    );

    if (response.routes.isEmpty) {
      return RouteResultEntity(
        errorMessage: response.errorMessage ?? 'No route found',
      );
    }

    final route = response.routes.first;
    final coords = (route.polylinePoints ?? [])
        .map((p) => RouteCoordinateEntity(latitude: p.latitude, longitude: p.longitude))
        .toList();

    return RouteResultEntity(
      points: coords,
      etaText: route.durationMinutes != null ? '${route.durationMinutes!.round()} Min' : null,
      distanceText: route.distanceKm != null ? '${route.distanceKm!.toStringAsFixed(1)} Km' : null,
    );
  }
}