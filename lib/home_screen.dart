
/*
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(23.86246002502454, 90.36608299415688),
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        mapType: MapType.normal,
        trafficEnabled: true,
        onTap: (LatLng latLng) {
          print(latLng);
        },
        onLongPress: (LatLng latLng) {
          print('Long pressed on $latLng');
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: <Marker>{
          Marker(
            markerId: MarkerId('my-home'),
            position: LatLng(23.870769958207607, 90.36518041044474),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
            visible: true,
            infoWindow: InfoWindow(
              title: 'My home',
              snippet: 'Where I live',
              onTap: () {
                print('My home Info window tapped');
              },
            ),
          ),
          Marker(
            markerId: MarkerId('my-office'),
            position: LatLng(23.874062459188128, 90.36553345620632),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            visible: true,
            infoWindow: InfoWindow(
              title: 'My office',
              snippet: 'Where I Works',
              onTap: () {
                print('My office Info window tapped');
              },
            ),
          ),
          Marker(
            markerId: MarkerId('location-picker'),
            position: LatLng(23.880125114390303, 90.36807183176279),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
            visible: true,
            draggable: true,
            onDragEnd: (LatLng latLng) {
              print('Marker drag end $latLng');
            },
            onDragStart: (LatLng latlng) {
              print('Marker dragged from $latlng');
            },
          ),
        },

        polylines: <Polyline>{
          Polyline(
            polylineId: PolylineId('my-route'),
            points: [
              LatLng(23.870769958207607, 90.36518041044474),
              LatLng(23.874062459188128, 90.36553345620632),
              LatLng(23.87486234737935, 90.36836218088865),
            ],
            color: Colors.blue,
            width: 4,
            visible: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        },
        circles: <Circle>{
          Circle(
            circleId: CircleId('office-circle'),
            center: LatLng(23.874062459188128, 90.36553345620632),
            radius: 45,
            fillColor: Colors.red.withAlpha(100),
            strokeColor: Colors.red,
            strokeWidth: 4,
          ),
          Circle(
            circleId: CircleId('home-circle'),
            center: LatLng(23.870769958207607, 90.36518041044474),
            radius: 35,
            fillColor: Colors.green.withAlpha(100),
            strokeColor: Colors.green,
            strokeWidth: 4,
          ),
        },
        polygons: <Polygon>{
          Polygon(
            polygonId: PolygonId('random-polygon'),
            points: [
              LatLng(23.877448383658074, 90.36301620304585),
              LatLng(23.877218754311055, 90.36478813737631),
              LatLng(23.875990889541157, 90.3635435923934),
              LatLng(23.87731379454415, 90.3619496896863),
              LatLng(23.877739941828086, 90.36489240825176),
              LatLng(23.877362540959204, 90.36480020731688),
              LatLng(23.876659548429544, 90.36461312323809),
            ],
            fillColor: Colors.purple.withAlpha(100),
            strokeColor: Colors.purple,
            strokeWidth: 4,
            onTap: () {
              print('This area is Markets');
            },
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /*
          // without animate
          _mapController.moveCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 16,
                target: LatLng(23.870769958207607, 90.36518041044474),
              ),
             ),
          );

           */
          // with animate
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 16,
              target: LatLng(23.870769958207607, 90.36518041044474),
            ),
          ),
          );
        },
        child: Icon(Icons.home),
      ),
    );
  }
}






 */