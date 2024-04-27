import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:vv/utils/token_manage.dart';

class NavigationScreen extends StatefulWidget {
  final double lat;
  final double lng;
  const NavigationScreen(this.lat, this.lng, {super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  loc.Location location = loc.Location();
  Marker? sourcePosition, destinationPosition;
  loc.LocationData? _currentPosition;
  LatLng curLocation = LatLng(23.0525, 72.5667);
  StreamSubscription<loc.LocationData>? locationSubscription;
  late HubConnection _connection;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    getNavigation();
    addMarker();
    initializeSignalR();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    _connection.stop();
  }

  Future<void> initializeSignalR() async {
    final token = await TokenManager.getToken();
    _connection = HubConnectionBuilder()
        .withUrl(
      'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/GPS',
      HttpConnectionOptions(
        accessTokenFactory: () => Future.value(token),
        logging: (level, message) => print(message),
      ),
    )
        .withAutomaticReconnect(
            [0, 2000, 10000, 30000]) // Configuring automatic reconnect
        .build();

    _connection.onclose((error) async {
      print('Connection closed. Error: $error');
      // Optionally initiate a manual reconnect here if automatic reconnect is not sufficient
      await reconnect();
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
      // Start sending location every minute after the connection is established
      _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        sendCurrentLocation();
      });
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      await reconnect();
    }
  }

  Future<void> reconnect() async {
    int retryInterval = 1000; // Initial retry interval to 5 seconds
    while (_connection.state != HubConnectionState.connected) {
      await Future.delayed(Duration(milliseconds: retryInterval));
      try {
        await _connection.start();
        print("Reconnected to SignalR server.");
        return; // Exit the loop if connected
      } catch (e) {
        print("Reconnect failed: $e");
        retryInterval = (retryInterval < 1000)
            ? retryInterval + 1000
            : 1000; // Increase retry interval, cap at 1 seconds
      }
    }
  }

  Future<void> sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      await _connection.invoke('SendGPSToFamilies',
          args: [position.latitude, position.longitude]);
      print('Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sourcePosition == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: CameraPosition(
                    target: curLocation,
                    zoom: 16,
                  ),
                  markers: {sourcePosition!, destinationPosition!},
                  onTap: (latLng) {
                    print(latLng);
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  top: 30,
                  left: 15,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.navigation_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await launchUrl(Uri.parse(
                                'google.navigation:q=${widget.lat}, ${widget.lng}&key=AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc')); // Replace YOUR_API_KEY with your actual API key
                          },
                        ),
                      ),
                    ))
              ],
            ),
    );
  }

  getNavigation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    final GoogleMapController? controller = await _controller.future;
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    if (_permissionGranted == loc.PermissionStatus.granted) {
      _currentPosition = await location.getLocation();
      curLocation =
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      locationSubscription =
          location.onLocationChanged.listen((loc.LocationData currentLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16,
        )));
        if (mounted) {
          controller
              ?.showMarkerInfoWindow(MarkerId(sourcePosition!.markerId.value));
          setState(() {
            curLocation =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            sourcePosition = Marker(
              markerId: MarkerId(currentLocation.toString()),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position:
                  LatLng(currentLocation.latitude!, currentLocation.longitude!),
              infoWindow: InfoWindow(
                  title:
                      '${double.parse((getDistance(LatLng(widget.lat, widget.lng)).toStringAsFixed(2)))} km'),
              onTap: () {
                print('market tapped');
              },
            );
          });
          getDirections(LatLng(widget.lat, widget.lng));
        }
      });
    }
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDc7BLNnR3cQAhlKRDUgpcZYssqgDIHWxc', // Replace YOUR_API_KEY with your actual API key
        PointLatLng(curLocation.latitude, curLocation.longitude),
        PointLatLng(dst.latitude, dst.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destposition) {
    return calculateDistance(curLocation.latitude, curLocation.longitude,
        destposition.latitude, destposition.longitude);
  }

  addMarker() {
    setState(() {
      sourcePosition = Marker(
        markerId: MarkerId('source'),
        position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      destinationPosition = Marker(
        markerId: MarkerId('destination'),
        position: LatLng(widget.lat, widget.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    });
  }

  Future<void> launchUrl(Uri uri) async {
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }
}