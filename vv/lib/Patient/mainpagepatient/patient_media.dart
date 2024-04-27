import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/Patient/mainpagepatient/fullscreenMedia.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart'; // Ensure this import has the necessary DioService setup
import 'package:vv/models/media_patient.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/models/media_item.dart'; // Importing the modified MediaItem model
import 'package:signalr_core/signalr_core.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:geolocator/geolocator.dart'; 
class GalleryScreenPatient extends StatefulWidget {
  @override
  _GalleryScreenPatientState createState() => _GalleryScreenPatientState();
}

class _GalleryScreenPatientState extends State<GalleryScreenPatient> {
   late HubConnection _connection;
  Timer? _locationTimer; // Initialize Dio
  List<MediaItempatient> mediaItems = [];

  @override
  void initState() {
    initializeSignalR();
    super.initState();
    fetchMedia(); // Initiating media fetching on state initialization
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
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _connection.invoke('SendGPSToFamilies',
          args: [position.latitude, position.longitude]);
      print('Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error sending location: $e');
    }
  }

   @override
  void dispose() {
    _locationTimer?.cancel(); // Cancel the timer when the widget is disposed
    _connection.stop(); // Optionally stop the connection
    super.dispose();
  }

  void fetchMedia() async {
    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetMedia');
      var data = response.data;
      List<MediaItempatient> fetchedItems = data
          .map<MediaItempatient>((item) => MediaItempatient(
                path: item['mediaUrl'],
                description: item['caption'],
                type: item['mediaExtension'] == '.mp4'
                    ? MediaType.video
                    : MediaType.image,
                isNetwork: true,
                uploadedDate: item['uploaded_date'], // Parsing uploaded date
                uploaderFamilyName: item[
                    'familyNameWhoUpload'], // Parsing uploader's family name
              ))
          .toList();
      setState(() {
        mediaItems = fetchedItems; // Updating the state with new media items
      });
    } catch (e) {
      print('Failed to fetch media: $e');
    }
  }

  void _viewMediaItem(MediaItempatient item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenViewerpatient(mediaItem: item),
      ),
    );
  }

  String formatDateString(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      // Format the date as 'dd MMM yyyy' (e.g., 13 Apr 2024). Modify this format to your liking.
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return dateString; // Return the original string if it can't be parsed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictures and Videos'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => mainpatient()),
            );
          },
        ),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: mediaItems.length,
          itemBuilder: (context, index) {
            var mediaItem = mediaItems[index];
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => _viewMediaItem(mediaItem),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: mediaItem.type == MediaType.image
                              ? Image.network(mediaItem.path, fit: BoxFit.cover)
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.network(mediaItem.path,
                                        fit: BoxFit.cover),
                                    const Icon(Icons.play_circle_outline,
                                        size: 50, color: Colors.white),
                                  ],
                                ),
                        ),
                        Text(mediaItem.description,
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                        Text(formatDateString(mediaItem.uploadedDate),
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey)), // Display the upload date
                        Text(mediaItem.uploaderFamilyName,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors
                                    .grey)) // Display the uploader's family name
                      ],
                    ),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
