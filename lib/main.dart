
// how

/*
import 'package:flutter/material.dart';
import 'package:google_maps_app/screens/map_screen.dart';
import 'package:provider/provider.dart';
//import 'package:real_time_location_tracker/screens/map_screen.dart';
//import 'package:real_time_location_tracker/providers/location_provider.dart';

import 'providers/location _provider.dart';

void main() {
  runApp(const RealTimeLocationTracker());
}

class RealTimeLocationTracker extends StatelessWidget {
  const RealTimeLocationTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Real-Time Location Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MapScreen(),
      ),
    );
  }
}

 */





import 'package:flutter/material.dart';
import 'package:google_maps_app/my_location_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //return const MaterialApp(home: HomeScreen());
    return const MaterialApp(home:RealTimeTrackerScreen());


  }
}




