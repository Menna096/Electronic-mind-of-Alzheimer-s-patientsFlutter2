import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/page/description_screen.dart';
import 'package:vv/page/full_screen_viewer.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:vv/widgets/background.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<MediaItem> mediaItems = [];
  late HubConnection _connection;
  String _currentLocation = "Waiting for location...";
  bool _locationReceived = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      var data = notificationResponse.payload!.split(',');
      double latitude = double.parse(data[0]);
      double longitude = double.parse(data[1]);
      _launchGoogleMaps(latitude, longitude);
    }
  }

  Future<void> initializeSignalR() async {
    _connection = HubConnectionBuilder()
        .withUrl(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/hubs/GPS',
          HttpConnectionOptions(
            accessTokenFactory: () async => await TokenManager.getToken(),
            logging: (level, message) => print(message),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection.on('ReceiveGPSToFamilies', (arguments) {
      if (arguments != null && arguments.length >= 2) {
        double latitude = arguments[0];
        double longitude = arguments[1];
        setState(() {
          _currentLocation = 'Latitude: $latitude, Longitude: $longitude';
          _locationReceived = true;
        });
        _showNotification(latitude, longitude);
        print('Location received: Latitude $latitude, Longitude $longitude');
      }
    });

    try {
      await _connection.start();
      print('SignalR connection established.');
    } catch (e) {
      print('Failed to start SignalR connection: $e');
      setState(() {
        _currentLocation = 'Error starting connection: $e';
      });
    }
  }

  Future<void> _showNotification(double latitude, double longitude) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      0,
      'New Location Received',
      'Latitude: $latitude, Longitude: $longitude',
      platformChannelSpecifics,
      payload: '$latitude,$longitude',
    );
  }

  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    final url = 'geo:0,0?q=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _connection.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchMedia();
    initializeSignalR(); // Fetch media when the screen initializes
  }

  void _addMedia() async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final isVideo = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Choose Media Type'),
              content: const Text('What do you want to take?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Photo'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Video'),
                ),
              ],
            ),
          ) ??
          false;

      XFile? pickedFile;
      MediaType type;

      if (isVideo) {
        // User chose to pick a video
        pickedFile = await picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 60),
        );
        type = MediaType.video;
      } else {
        // User chose to pick an image
        pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );
        type = MediaType.image;
      }

      if (pickedFile != null) {
        // Navigate to the DescriptionScreen and wait for the result
        final MediaItem? newMediaItem = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DescriptionScreen(
              mediaPath: pickedFile!.path,
              type: type,
            ),
          ),
        );

        // If a new media item was added, update the list and UI
        if (newMediaItem != null) {
          setState(() {
            mediaItems.add(newMediaItem);
          });
        }
      }
    }
  }

  void fetchMedia() async {
    // Using Dio to perform a GET request

    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetMediaForFamily');
      var data = response.data;
      // Assuming data is a list of media items
      List<MediaItem> fetchedItems = data
          .map<MediaItem>((item) => MediaItem(
                path: item['mediaUrl'],
                description: item['caption'],
                type: item['mediaExtension'] == '.mp4'
                    ? MediaType.video
                    : MediaType.image,
                isNetwork: true,
              ))
          .toList();
      setState(() {
        mediaItems = fetchedItems;
      });
    } catch (e) {
      print('Failed to fetch media: $e');
      // Handle exception by showing a message to the user or retrying
    }
  }

  void _viewMediaItem(MediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenViewer(mediaItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pictures and Videos')),
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
                    child: mediaItem.type == MediaType.image
                        ? Image.network(mediaItem.path, fit: BoxFit.cover)
                        : const DecoratedBox(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'images/vid.png'), // Use the placeholder image for videos
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Icon(Icons.play_circle_outline,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                  ),
                ));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedia,
        child: const Icon(Icons.add),
      ),
    );
  }
}
