import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/station_location_entity.dart';
import '../bloc/map_cubit.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  late final MapCubit _mapCubit;

  @override
  void initState() {
    super.initState();
    _mapCubit = di.sl<MapCubit>()..loadStations();
  }

  Set<Marker> _buildMarkers(MapState state) {
    final userPos = LatLng(state.userLatitude, state.userLongitude);
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user_location'),
        position: userPos,
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    for (final station in state.stations) {
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          onTap: () => _mapCubit.selectStation(station),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(MapState state) {
    if (state.routePoints.isEmpty) return const {};

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: state.routePoints.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: const Color(0xFF2563EB),
        width: 5,
      ),
    };
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude;
    double x1 = list.first.latitude;
    double y0 = list.first.longitude;
    double y1 = list.first.longitude;

    for (final latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_darkMapStyle);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapCubit,
      child: BlocConsumer<MapCubit, MapState>(
        listenWhen: (prev, curr) =>
        prev.routePoints != curr.routePoints &&
            curr.routePoints.isNotEmpty &&
            curr.selectedStation != null,
        listener: (context, state) {
          final station = state.selectedStation!;
          final userPos = LatLng(state.userLatitude, state.userLongitude);
          final destPos = LatLng(station.latitude, station.longitude);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList([userPos, destPos]),
              100.0,
            ),
          );
        },
        builder: (context, state) {
          final userPos = LatLng(state.userLatitude, state.userLongitude);

          return Scaffold(
            backgroundColor: const Color(0xFF0A0A0A),
            body: Stack(
              children: [
                GoogleMap(
                  padding: const EdgeInsets.only(bottom: 160.0, right: 10.0),
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: userPos,
                    zoom: 14.0,
                  ),
                  markers: _buildMarkers(state),
                  polylines: _buildPolylines(state),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  onTap: (_) => _mapCubit.clearSelection(),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: state.selectedStation == null
                        ? _buildSearchBar()
                        : _buildRouteHeader(state.selectedStation!),
                  ),
                ),

                if (state.selectedStation != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: _buildStationDetailsCard(state, state.selectedStation!),
                  ),

                if (state.selectedStation == null)
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: "btn_nearest",
                          backgroundColor: const Color(0xFF161B22),
                          onPressed: _mapCubit.findNearestStation,
                          child: const Icon(Icons.electric_bolt, color: Colors.yellow),
                        ),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          heroTag: "btn_location",
                          backgroundColor: const Color(0xFF161B22),
                          onPressed: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(userPos, 14.0),
                            );
                          },
                          child: const Icon(Icons.my_location, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        children: [
          SizedBox(width: 16),
          Icon(Icons.search, color: Colors.white54),
          SizedBox(width: 12),
          Text("Search Location Or Charger", style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRouteHeader(StationLocationEntity station) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _mapCubit.clearSelection,
          ),
          Expanded(
            child: Text(
              station.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _mapCubit.clearSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildStationDetailsCard(MapState state, StationLocationEntity station) {
    final distanceKm = _mapCubit.calculateDistanceKm(
      state.userLatitude,
      state.userLongitude,
      station.latitude,
      station.longitude,
    );
    final bool isNear = distanceKm <= 0.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${state.realTimeEta ?? station.eta} (${state.realTimeDistance ?? station.distance})",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            station.routeName,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("CCS2", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        const Text("Available", style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(station.power, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(station.price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isNear ? () {} : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: isNear ? const Color(0xFF2563EB) : Colors.white24),
                backgroundColor: isNear ? Colors.transparent : Colors.white10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isNear ? "Start Charging" : "Drive Closer To Charge",
                style: TextStyle(
                  color: isNear ? const Color(0xFF2563EB) : Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String _darkMapStyle = '''
[
  { "elementType": "geometry", "stylers": [{"color": "#212121"}] },
  { "elementType": "labels.icon", "stylers": [{"visibility": "off"}] },
  { "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}] },
  { "elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}] },
  { "featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}] },
  { "featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}] },
  { "featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}] }
]
''';