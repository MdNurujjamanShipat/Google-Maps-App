
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_app/widgets/control_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/location _provider.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  bool _showUserMarkerDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.getInitialLocation();
    locationProvider.startRealTimeUpdates();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
    _animateToCurrentLocation();
  }

  Future<void> _animateToCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();

    if (locationProvider.currentPosition != null && _mapController != null) {
      final CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        ),
        zoom: 16.0,
        tilt: 60.0,
        bearing: 30.0,
      );

      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    }
  }

  Future<void> _animateToUserMarker() async {
    final locationProvider = context.read<LocationProvider>();

    if (locationProvider.userMarkerPosition != null && _mapController != null) {
      final CameraPosition cameraPosition = CameraPosition(
        target: locationProvider.userMarkerPosition!,
        zoom: 16.0,
        tilt: 60.0,
        bearing: 30.0,
      );

      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    }
  }

  void _onMapLongPress(LatLng position) {
    _showAddMarkerDialog(position);
  }

  Future<void> _showAddMarkerDialog(LatLng position) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController snippetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Marker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Marker Title (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: snippetController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Text(
              'Position: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final locationProvider = context.read<LocationProvider>();
              locationProvider.setUserMarker(
                position,
                title: titleController.text.isNotEmpty ? titleController.text : null,
                snippet: snippetController.text.isNotEmpty ? snippetController.text : null,
              );
              Navigator.pop(context);
              _animateToUserMarker();
            },
            child: const Text('Add Marker'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              final initialPosition = locationProvider.currentPosition;

              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: initialPosition != null
                      ? LatLng(initialPosition.latitude, initialPosition.longitude)
                      : const LatLng(0.0, 0.0),
                  zoom: 16.0,
                ),
                onLongPress: _onMapLongPress,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: false,
                polylines: locationProvider.polylines,
                markers: locationProvider.markers,
              );
            },
          ),

          // App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildAppBar(),
          ),

          // Control Panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ControlPanel(
              onCenterPressed: _animateToCurrentLocation,
              onUserMarkerPressed: _animateToUserMarker,
            ),
          ),

          // Location Info
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 20,
            right: 20,
            child: _buildLocationInfo(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Real-Time Location Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.currentPosition == null) {
          return Container();
        }

        final position = locationProvider.currentPosition!;
        final distance = locationProvider.calculateDistanceToUserMarker();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: locationProvider.isTracking ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    locationProvider.isTracking ? 'Tracking Active' : 'Tracking Inactive',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: locationProvider.isTracking ? Colors.green : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (locationProvider.userMarkerPosition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.place, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Custom Marker',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Latitude', position.latitude.toStringAsFixed(6)),
              _buildInfoRow('Longitude', position.longitude.toStringAsFixed(6)),
              _buildInfoRow('Accuracy', '${position.accuracy?.toStringAsFixed(2) ?? 'N/A'} m'),
              _buildInfoRow('Points Tracked', locationProvider.locationHistory.length.toString()),

              if (distance != null)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Distance to Marker',
                      '${distance.toStringAsFixed(2)} m',
                      valueColor: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            if (locationProvider.userMarkerPosition != null) {
              return FloatingActionButton.small(
                onPressed: () {
                  locationProvider.removeUserMarker();
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              );
            }
            return Container();
          },
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => _buildInstructions(),
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.help_outline, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildInstructionItem(
            Icons.place,
            'Blue Marker',
            'Your current location (updates in real-time)',
            Colors.blue,
          ),
          _buildInstructionItem(
            Icons.place,
            'Red Marker',
            'Custom marker you can place anywhere (long press on map)',
            Colors.red,
          ),
          _buildInstructionItem(
            Icons.drag_indicator,
            'Drag Marker',
            'Drag the red marker to reposition it',
            Colors.red,
          ),
          _buildInstructionItem(
            Icons.timeline,
            'Blue Line',
            'Tracks your movement path',
            Colors.blue,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tip: Long press anywhere on the map to add a custom marker!',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

 */





/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_app/widgets/control_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
//import 'package:real_time_location_tracker/providers/location_provider.dart';
//import 'package:real_time_location_tracker/widgets/control_panel.dart';

import '../providers/location _provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controller = Completer();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.getInitialLocation();
    locationProvider.startRealTimeUpdates();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
    _isMapReady = true;
    _animateToCurrentLocation();
  }

  Future<void> _animateToCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();

    if (locationProvider.currentPosition != null && _mapController != null) {
      final CameraPosition cameraPosition = CameraPosition(
        target: LatLng(
          locationProvider.currentPosition!.latitude,
          locationProvider.currentPosition!.longitude,
        ),
        zoom: 16.0,
        tilt: 60.0,
        bearing: 30.0,
      );

      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              final initialPosition = locationProvider.currentPosition;

              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: initialPosition != null
                      ? LatLng(initialPosition.latitude, initialPosition.longitude)
                      : const LatLng(0.0, 0.0),
                  zoom: 15.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: true,
                zoomControlsEnabled: false,
                polylines: locationProvider.polylines,
                markers: locationProvider.markers,
                onTap: (_) {
                  // Close any open info windows when tapping on map
                },
              );
            },
          ),

          // App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildAppBar(),
          ),

          // Control Panel
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ControlPanel(
              onCenterPressed: _animateToCurrentLocation,
            ),
          ),

          // Location Info
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 20,
            right: 20,
            child: _buildLocationInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Real-Time Location Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.currentPosition == null) {
          return Container();
        }

        final position = locationProvider.currentPosition!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: locationProvider.isTracking ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    locationProvider.isTracking ? 'Tracking Active' : 'Tracking Inactive',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: locationProvider.isTracking ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Latitude', position.latitude.toStringAsFixed(6)),
              _buildInfoRow('Longitude', position.longitude.toStringAsFixed(6)),
              _buildInfoRow('Accuracy', '${position.accuracy?.toStringAsFixed(2) ?? 'N/A'} m'),
              _buildInfoRow('Points Tracked', locationProvider.locationHistory.length.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

 */


