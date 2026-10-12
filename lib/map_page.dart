import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;

  // Initial camera position (Set to Gurugram, you can update this to dynamic GPS later)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(28.4595, 77.0266),
    zoom: 14.0,
  );

  // Set to hold our charging station markers
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    // Adding the "ChargeOn Highway Hub" marker from your dashboard
    _markers.add(
      Marker(
        markerId: const MarkerId('charge_on_hub_1'),
        position: const LatLng(28.4595, 77.0266),
        infoWindow: const InfoWindow(
          title: 'ChargeOn Highway Hub',
          snippet: '60kW DC Fast • ₹18 / KWh',
        ),
        // Make the marker Green to represent EV charging
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Applies the custom dark JSON style to match your app's theme perfectly
    // _mapController.setMapStyle(_darkMapStyle);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // 1. The Google Map Layer
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: false, // Shows the blue dot for the user's location
            myLocationButtonEnabled: false, // Disabled default button to use our custom dark one
            zoomControlsEnabled: false, // Hides default zoom controls for a cleaner UI
            mapToolbarEnabled: false,
          ),

          // 2. Custom Top Search/Filter Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 16),
                          Icon(Icons.search, color: Colors.white54),
                          SizedBox(width: 12),
                          Text(
                            "Search charging stations...",
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB), // Brand blue
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () {
                        // Open filter bottom sheet
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Custom Re-center Location Button
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF161B22),
              onPressed: () {
                // Animates the camera back to the initial position
                _mapController.animateCamera(
                  CameraUpdate.newCameraPosition(_initialPosition),
                );
              },
              child: const Icon(Icons.my_location, color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal Dark Mode Map JSON array (removes bright colors and white roads)
const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';