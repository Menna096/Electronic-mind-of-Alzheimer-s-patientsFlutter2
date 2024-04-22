import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline example',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  late LocationData currentLocation;
  double _destLatitude = 30.000775847392234;
  double _destLongitude = 32.48482218702964;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc";
  bool _isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLocationLoaded
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                onMapCreated: _onMapCreated,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;

    // Add marker for destination location
    LatLng destinationPosition = LatLng(_destLatitude, _destLongitude);
    MarkerId destinationMarkerId = MarkerId('destination');
    Marker destinationMarker = Marker(
      markerId: destinationMarkerId,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker for destination
      position: destinationPosition,
    );
    markers[destinationMarkerId] = destinationMarker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _getCurrentLocation() async {
    var location = Location();
    try {
      currentLocation = await location.getLocation();
      _addMarker(
        LatLng(currentLocation.latitude!, currentLocation.longitude!),
        "origin",
        BitmapDescriptor.defaultMarker,
      );
      _getPolyline();
      setState(() {
        _isLocationLoaded = true;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(currentLocation.latitude!, currentLocation.longitude!),
      PointLatLng(_destLatitude, _destLongitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
