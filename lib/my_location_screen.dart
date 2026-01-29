
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RealTimeTrackerScreen extends StatefulWidget {
  const RealTimeTrackerScreen({super.key});

  @override
  State<RealTimeTrackerScreen> createState() => _RealTimeTrackerScreenState();
}

class _RealTimeTrackerScreenState extends State<RealTimeTrackerScreen> {
  late GoogleMapController _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _locationHistory = [];
  bool _isLocationPermissionGranted = false;
  bool _isFirstLocation = true;

  // Location update interval (10 seconds as per requirement)
  static const Duration _locationUpdateInterval = Duration(seconds: 10);

  // Timer for manual location updates (fallback)
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  Future<void> _initializeLocationTracking() async {
    await _checkLocationPermission();

    // Start periodic location updates as a fallback
    _startPeriodicLocationUpdates();
  }

  Future<void> _checkLocationPermission() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Show dialog to open settings
      _showPermissionDeniedDialog();
      return;
    }

    _isLocationPermissionGranted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (_isLocationPermissionGranted) {
      _startRealTimeLocationUpdates();
      // Get initial location
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(position);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _showPermissionDeniedDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('This app needs location permission to track your real-time location. Please enable it in settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    });
  }

  void _startRealTimeLocationUpdates() {
    // Start listening to position stream
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update when moving 10 meters
      ),
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _startPeriodicLocationUpdates() {
    // As a fallback, also update location every 10 seconds
    _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (timer) async {
      if (_isLocationPermissionGranted) {
        await _getCurrentLocation();
      }
    });
  }

  void _updateLocation(Position position) {
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      final LatLng newLocation = LatLng(position.latitude, position.longitude);

      // Add to location history
      _locationHistory.add(newLocation);

      // Update marker
      _updateMarker(newLocation);

      // Update polyline
      _updatePolyline();

      // Animate to location if it's the first update
      if (_isFirstLocation && _mapController != null) {
        _animateToLocation(newLocation);
        _isFirstLocation = false;
      }
    });
  }

  void _updateMarker(LatLng location) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'My Current Location',
          snippet: '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        ),
        onTap: () {
          // Info window is already configured to show on tap
        },
      ),
    );
  }

  void _updatePolyline() {
    if (_locationHistory.length > 1) {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('tracking_line'),
          points: _locationHistory,
          color: Colors.blue,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }
  }

  void _animateToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _clearTracking() {
    setState(() {
      _locationHistory.clear();
      _polylines.clear();
    });
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    if (_mapController != null) {
      _mapController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Location Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearTracking,
            tooltip: 'Clear tracking history',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Geolocator.openAppSettings();
            },
            tooltip: 'Open location settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(23.7216771, 90.4165835), // Default location from your image
              zoom: 16.0,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll use custom button
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // Location info panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      if (_currentPosition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_currentPosition != null) ...[
                    _buildInfoRow('Latitude:', _currentPosition!.latitude.toStringAsFixed(6)),
                    _buildInfoRow('Longitude:', _currentPosition!.longitude.toStringAsFixed(6)),
                    _buildInfoRow('Accuracy:', '±${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
                    if (_currentPosition!.speed > 0)
                      _buildInfoRow('Speed:', '${_currentPosition!.speed.toStringAsFixed(1)} m/s'),
                    if (_locationHistory.length > 1)
                      _buildInfoRow('Points tracked:', _locationHistory.length.toString()),
                  ] else ...[
                    const Text(
                      'Waiting for location...',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Get Location'),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Control buttons
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: () {
                    if (_currentPosition != null) {
                      _animateToLocation(
                        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      );
                    } else {
                      // Center on default location
                      _animateToLocation(const LatLng(23.7216771, 90.4165835));
                    }
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                  tooltip: 'Center on my location',
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: () {
                    _mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.blue),
                  tooltip: 'Zoom in',
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: () {
                    _mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.blue),
                  tooltip: 'Zoom out',
                ),
              ],
            ),
          ),

          // Static locations list (from your image)
          Positioned(
            bottom: 200,
            left: 16,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.place, size: 16, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Nearby Locations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildLocationItem('🏫', 'Shek Long Bangla/Baikia Mahavidyalaaya'),
                          _buildLocationItem('🛒', 'Peshwaian'),
                          _buildLocationItem('🛍️', 'Shwapno - Wari'),
                          _buildLocationItem('🍕', 'PizzaBurg Wari'),
                          _buildLocationItem('🛍️', 'Aarong Wari'),
                          _buildLocationItem('🌳', 'Bangathabaran Garden'),
                          _buildLocationItem('🛕', 'Jai Kali Temple'),
                          _buildLocationItem('🛒', 'Peshwarain'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating action button to center on location
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _animateToLocation(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            );
          } else {
            // For testing/demo: Use default location
            _animateToLocation(const LatLng(23.7216771, 90.4165835));
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.gps_fixed, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}









// completed 50 minutes.
// user real time location monitor kora .
// like user waking that user realtime location monitor kora.
// oi user location latitude draw in google map . like it will be line type ,
// like line type exam real google map location line type .
//53 minutes video .
//real time application taker use google map and gps service .
// if you want then you can use intermideate type calculation kore firbase er modde rakte paren