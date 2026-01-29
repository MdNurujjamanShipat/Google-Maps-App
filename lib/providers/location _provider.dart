

/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider with ChangeNotifier {
  // Location tracking variables
  Position? _currentPosition;
  List<LatLng> _locationHistory = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _isTracking = false;
  bool _permissionGranted = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  // User-set marker
  LatLng? _userMarkerPosition;
  String? _userMarkerTitle;
  String? _userMarkerSnippet;

  // Getters
  Position? get currentPosition => _currentPosition;
  List<LatLng> get locationHistory => _locationHistory;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;
  bool get isTracking => _isTracking;
  bool get permissionGranted => _permissionGranted;
  LatLng? get userMarkerPosition => _userMarkerPosition;

  // Check and request location permissions
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _permissionGranted = false;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _permissionGranted = false;
      notifyListeners();
      return false;
    }

    _permissionGranted = true;
    notifyListeners();
    return true;
  }

  // Get initial location
  Future<void> getInitialLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _currentPosition = position;
      _locationHistory.add(LatLng(position.latitude, position.longitude));

      // Create initial markers
      _updateAllMarkers();

      notifyListeners();
    } catch (e) {
      print("Error getting initial location: $e");
    }
  }

  // Start real-time location updates
  void startRealTimeUpdates() {
    if (!_permissionGranted || _isTracking) return;

    _isTracking = true;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateLocation(position);
    });

    notifyListeners();
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _positionStreamSubscription?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  // Update location and draw polyline
  void _updateLocation(Position newPosition) {
    if (_currentPosition != null) {
      // Add new point to history
      LatLng newLatLng = LatLng(newPosition.latitude, newPosition.longitude);
      _locationHistory.add(newLatLng);

      // Create polyline between current and new position
      _createPolyline(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        newLatLng,
      );
    }

    _currentPosition = newPosition;

    // Update markers
    _updateAllMarkers();

    notifyListeners();
  }

  // Create polyline between two points
  void _createPolyline(LatLng start, LatLng end) {
    final String polylineId = 'polyline_${_polylines.length}';

    final Polyline polyline = Polyline(
      polylineId: PolylineId(polylineId),
      color: Colors.blue,
      width: 5,
      points: [start, end],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    _polylines.add(polyline);
  }

  // Update all markers (current location + user marker)
  void _updateAllMarkers() {
    _markers.clear();

    // Add current location marker
    if (_currentPosition != null) {
      _addCurrentLocationMarker();
    }

    // Add user-set marker if exists
    if (_userMarkerPosition != null) {
      _addUserMarker();
    }
  }

  // Add current location marker

  void _addCurrentLocationMarker() {
    final Marker marker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      infoWindow: InfoWindow(
        title: 'My Current Location',
        snippet: 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      draggable: false,
      anchor: const Offset(0.5, 0.5),
    );

    _markers.add(marker);
  }


  // Add user-set marker
  void _addUserMarker() {
    final Marker marker = Marker(
      markerId: const MarkerId('user_marker'),
      position: _userMarkerPosition!,
      infoWindow: InfoWindow(
        title: _userMarkerTitle ?? 'Custom Marker',
        snippet: _userMarkerSnippet ?? 'Lat: ${_userMarkerPosition!.latitude.toStringAsFixed(6)}\nLng: ${_userMarkerPosition!.longitude.toStringAsFixed(6)}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      draggable: true,
      anchor: const Offset(0.5, 1.0),
      onDragEnd: (LatLng newPosition) {
        _userMarkerPosition = newPosition;
        notifyListeners();
      },
    );

    _markers.add(marker);
  }

  // Set user marker at specific position
  void setUserMarker(LatLng position, {String? title, String? snippet}) {
    _userMarkerPosition = position;
    _userMarkerTitle = title;
    _userMarkerSnippet = snippet;
    _updateAllMarkers();
    notifyListeners();
  }

  // Remove user marker
  void removeUserMarker() {
    _userMarkerPosition = null;
    _userMarkerTitle = null;
    _userMarkerSnippet = null;
    _updateAllMarkers();
    notifyListeners();
  }

  // Calculate distance between current location and user marker
  double? calculateDistanceToUserMarker() {
    if (_currentPosition == null || _userMarkerPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _userMarkerPosition!.latitude,
      _userMarkerPosition!.longitude,
    );
  }

  // Clear all polylines
  void clearPolylines() {
    _polylines.clear();
    _locationHistory.clear();
    notifyListeners();
  }

  // Clear everything (polylines + user marker)
  void clearAll() {
    _polylines.clear();
    _locationHistory.clear();
    removeUserMarker();
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

 */




/*

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider with ChangeNotifier {
  // Location tracking variables
  Position? _currentPosition;
  List<LatLng> _locationHistory = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _isTracking = false;
  bool _permissionGranted = false;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Getters
  Position? get currentPosition => _currentPosition;
  List<LatLng> get locationHistory => _locationHistory;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;
  bool get isTracking => _isTracking;
  bool get permissionGranted => _permissionGranted;

  // Check and request location permissions
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        _permissionGranted = false;
        notifyListeners();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _permissionGranted = false;
      notifyListeners();
      return false;
    }

    _permissionGranted = true;
    notifyListeners();
    return true;
  }

  // Get initial location
  Future<void> getInitialLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      _currentPosition = position;
      _locationHistory.add(LatLng(position.latitude, position.longitude));

      // Create initial marker
      _createMarker(position);

      notifyListeners();
    } catch (e) {
      print("Error getting initial location: $e");
    }
  }

  // Start real-time location updates
  void startRealTimeUpdates() {
    if (!_permissionGranted || _isTracking) return;

    _isTracking = true;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Update every 5 meters (changed from 10 seconds for better accuracy)
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateLocation(position);
    });

    notifyListeners();
  }

  // Stop real-time updates
  void stopRealTimeUpdates() {
    _positionStreamSubscription?.cancel();
    _isTracking = false;
    notifyListeners();
  }

  // Update location and draw polyline
  void _updateLocation(Position newPosition) {
    if (_currentPosition != null) {
      // Add new point to history
      LatLng newLatLng = LatLng(newPosition.latitude, newPosition.longitude);
      _locationHistory.add(newLatLng);

      // Create polyline between current and new position
      _createPolyline(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        newLatLng,
      );
    }

    _currentPosition = newPosition;

    // Update marker position
    _updateMarker(newPosition);

    notifyListeners();
  }

  // Create polyline between two points
  void _createPolyline(LatLng start, LatLng end) {
    final String polylineId = 'polyline_${_polylines.length}';

    final Polyline polyline = Polyline(
      polylineId: PolylineId(polylineId),
      color: Colors.blue,
      width: 5,
      points: [start, end],
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    _polylines.add(polyline);
  }

  // Create or update marker
  void _createMarker(Position position) {
    const String markerId = 'current_location';

    final Marker marker = Marker(
      markerId: const MarkerId(markerId),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(
        title: 'My current location',
        snippet: 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      draggable: false,
      onTap: () {
        // Marker tap handled in UI
      },
    );

    _markers.clear(); // Clear previous markers
    _markers.add(marker);
  }

  void _updateMarker(Position position) {
    _markers.clear();
    _createMarker(position);
  }

  // Clear all polylines
  void clearPolylines() {
    _polylines.clear();
    _locationHistory.clear();
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}

 */


