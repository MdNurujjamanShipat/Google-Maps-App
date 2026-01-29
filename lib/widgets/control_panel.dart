

/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:google_maps_app/providers/location_provider.dart';

import '../providers/location _provider.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onCenterPressed;
  final VoidCallback onUserMarkerPressed;

  const ControlPanel({
    super.key,
    required this.onCenterPressed,
    required this.onUserMarkerPressed,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Center to Current Location
          _buildControlButton(
            icon: Icons.gps_fixed,
            label: 'My Location',
            onPressed: onCenterPressed,
            color: Colors.blue,
          ),

          // Center to User Marker (only if exists)
          if (locationProvider.userMarkerPosition != null)
            _buildControlButton(
              icon: Icons.place,
              label: 'To Marker',
              onPressed: onUserMarkerPressed,
              color: Colors.red,
            ),

          // Start/Stop Tracking
          _buildControlButton(
            icon: locationProvider.isTracking ? Icons.pause : Icons.play_arrow,
            label: locationProvider.isTracking ? 'Pause' : 'Track',
            onPressed: () {
              if (locationProvider.isTracking) {
                locationProvider.stopRealTimeUpdates();
              } else {
                locationProvider.startRealTimeUpdates();
              }
            },
            color: locationProvider.isTracking ? Colors.orange : Colors.green,
          ),

          // Clear All
          _buildControlButton(
            icon: Icons.delete_sweep,
            label: 'Clear All',
            onPressed: locationProvider.clearAll,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [


        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

 */






/*

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:real_time_location_tracker/providers/location_provider.dart';

import '../providers/location _provider.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onCenterPressed;

  const ControlPanel({
    super.key,
    required this.onCenterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Center Map Button
          _buildControlButton(
            icon: Icons.center_focus_strong,
            label: 'Center',
            onPressed: onCenterPressed,
            color: Colors.blue,
          ),

          // Start/Stop Tracking Button
          _buildControlButton(
            icon: locationProvider.isTracking ? Icons.pause : Icons.play_arrow,
            label: locationProvider.isTracking ? 'Pause' : 'Start',
            onPressed: () {
              if (locationProvider.isTracking) {
                locationProvider.stopRealTimeUpdates();
              } else {
                locationProvider.startRealTimeUpdates();
              }
            },
            color: locationProvider.isTracking ? Colors.orange : Colors.green,
          ),

          // Clear Path Button
          _buildControlButton(
            icon: Icons.delete_outline,
            label: 'Clear Path',
            onPressed: locationProvider.clearPolylines,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

 */

