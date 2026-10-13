import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;

// Custom Data Class to store the charging station details
// Shows only the charging station that are available
class ChargingStation {
  final String id;
  final String name;
  final LatLng location;
  final String eta;
  final String distance;
  final String routeName;
  final String power;
  final String price;
  final double markerHue;

  ChargingStation({
    required this.id,
    required this.name,
    required this.location,
    required this.eta,
    required this.distance,
    required this.routeName,
    required this.power,
    required this.price,
    required this.markerHue,
  });
}

// Widget Tree
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

// State Object Class
class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;

  final String googleApiKey = dotenv.env['MAPS_API_KEY'] ?? '';
  // Dummy fixed Current location
  final LatLng _currentPosition = const LatLng(28.435472, 77.082348);

  // Variables that are used to count the real time (Estimated Time Arrival and Real time distance from the Current Location)
  String? _realTimeEta;
  String? _realTimeDistance;

  // Dummy filling of near by charging Station in the map
  final List<ChargingStation> _stations = [
    // Charging Station1 made using the custom data class
    ChargingStation(
      id: '1',
      name: 'Ardee City Fast Charger',
      location: const LatLng(28.4380, 77.0800),
      eta: '4 Min',
      distance: '1.2 Km',
      routeName: 'Fastest Route Via Ardee Marg',
      power: '60kW DC Fast',
      price: '₹18 / KWh',
      markerHue: BitmapDescriptor.hueGreen,
    ),
    // Charging Station2 made using the custom data class
    ChargingStation(
      id: '2',
      name: 'Wazirabad Hub',
      location: const LatLng(28.4320, 77.0850),
      eta: '3 Min',
      distance: '0.8 Km',
      routeName: 'Fastest Route Via Main Rd',
      power: '120kW DC Ultra Fast',
      price: '₹22 / KWh',
      markerHue: BitmapDescriptor.hueOrange,
    ),
    // Charging Station3 made using the custom data class
    ChargingStation(
      id: '3',
      name: 'Sector 52 Plaza',
      location: const LatLng(28.4360, 77.0750),
      eta: '6 Min',
      distance: '1.5 Km',
      routeName: 'Fastest Route Via Sector Rd',
      power: '30kW AC Slow',
      price: '₹15 / KWh',
      markerHue: BitmapDescriptor.hueRed,
    ),
  ];

  ChargingStation? _selectedStation;
  // Marker is the data type provider by the Google maps Flutter extension to add all the marked location in the map view
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // function that initiates the marker in the map to show the details of all the available Charging Station Location
    _initializeMarkers();
  }

  void _initializeMarkers() {
    // Addition of the Current Location in the map
    // adding up the current location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _currentPosition,
        infoWindow: const InfoWindow(title: 'My Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // adding all the charging station marker
    // shows all the manually fed details of the Charging Stations
    for (var station in _stations) {
      _markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: station.location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          // on taping select the taped station as the to go station
          // calls the function
          onTap: () => _onStationSelected(station),
        ),
      );
    }
  }

  // Find the absolute closest station and select it
  void _findNearestStation() {
    if (_stations.isEmpty) return;

    ChargingStation? nearestStation;
    double minDistance = double.infinity;

    for (var station in _stations) {
      double dist = _calculateDistance(_currentPosition, station.location);
      if (dist < minDistance) {
        minDistance = dist;
        nearestStation = station;
      }
    }

    if (nearestStation != null) {
      _onStationSelected(nearestStation);
    }
  }

  // Fetch Live Traffic Route
  Future<void> _onStationSelected(ChargingStation station) async {
    setState(() {
      _selectedStation = station;
      _polylines.clear();
      _realTimeEta = "Calculating...";
      _realTimeDistance = "...";
    });

    PolylinePoints polylinePoints = PolylinePoints(apiKey: googleApiKey);

    // Requesting actual live traffic data
    RoutesApiResponse response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(_currentPosition.latitude, _currentPosition.longitude),
        destination: PointLatLng(station.location.latitude, station.location.longitude),
        travelMode: TravelMode.driving,
        routingPreference: RoutingPreference.trafficAware,
      ),
    );

    if (response.routes.isNotEmpty) {
      var route = response.routes.first;

      List<LatLng> polylineCoordinates = [];
      if (route.polylinePoints != null) {
        for (var point in route.polylinePoints!) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      setState(() {
        // Apply live data from Google API
        _realTimeEta = route.durationMinutes != null
            ? "${route.durationMinutes!.round()} Min"
            : station.eta;

        _realTimeDistance = route.distanceKm != null
            ? "${route.distanceKm!.toStringAsFixed(1)} Km"
            : station.distance;

        if (polylineCoordinates.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: const Color(0xFF2563EB),
              width: 5,
            ),
          );
        }
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList([_currentPosition, station.location]),
          100.0,
        ),
      );
    } else {
      setState(() {
        _realTimeEta = "Failed";
        _realTimeDistance = "Failed";
      });
      print("Error fetching route: ${response.errorMessage}");
    }
  }

  // Syntax repaired: Calculates real-world distance in kilometers
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var a = 0.5 - math.cos((pos2.latitude - pos1.latitude) * p) / 2 +
        math.cos(pos1.latitude * p) * math.cos(pos2.latitude * p) *
            (1 - math.cos((pos2.longitude - pos1.longitude) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.setMapStyle(_darkMapStyle);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _clearSelection() {
    setState(() {
      _selectedStation = null;
      _polylines.clear();
      _realTimeEta = null;
      _realTimeDistance = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Children number one the base --> the Google map base view
          GoogleMap(
            // Adds padding to push native Google UI (zoom buttons/logo) above your custom buttons
            padding: const EdgeInsets.only(bottom: 160.0, right: 10.0),
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onTap: (_) => _clearSelection(),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _selectedStation == null
                  ? _buildSearchBar()
                  : _buildRouteHeader(),
            ),
          ),
          if (_selectedStation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildStationDetailsCard(_selectedStation!),
            ),

          // Action Buttons: Find Nearest & Re-center
          if (_selectedStation == null)
            Positioned(
              bottom: 24,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: "btn_nearest",
                    backgroundColor: const Color(0xFF161B22),
                    onPressed: _findNearestStation,
                    child: const Icon(Icons.electric_bolt, color: Colors.yellow),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: "btn_location",
                    backgroundColor: const Color(0xFF161B22),
                    onPressed: () {
                      _mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentPosition, 14.0),
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
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: const [
          SizedBox(width: 16),
          Icon(Icons.search, color: Colors.white54),
          SizedBox(width: 12),
          Text("Search Location Or Charger", style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
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
            onPressed: _clearSelection,
          ),
          Expanded(
            child: Text(
              _selectedStation!.name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _clearSelection,
          ),
        ],
      ),
    );
  }

  Widget _buildStationDetailsCard(ChargingStation station) {
    double distanceKm = _calculateDistance(_currentPosition, station.location);
    bool isNear = distanceKm <= 0.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // Displays Live Data
            "${_realTimeEta ?? station.eta} (${_realTimeDistance ?? station.distance})",
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
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle)),
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
                      fontWeight: FontWeight.bold
                  )
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