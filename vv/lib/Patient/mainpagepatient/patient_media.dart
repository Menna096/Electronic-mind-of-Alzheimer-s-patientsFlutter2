import 'package:flutter/material.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';

import 'package:vv/api/login_api.dart';
import 'package:vv/models/media_item.dart';

import 'package:vv/page/full_screen_viewer.dart';
import 'package:vv/page/home_page.dart';
import 'package:vv/widgets/background.dart';

class GalleryScreenPatient extends StatefulWidget {
  @override
  _GalleryScreenPatientState createState() => _GalleryScreenPatientState();
}

class _GalleryScreenPatientState extends State<GalleryScreenPatient> {
  List<MediaItem> mediaItems = [];

  @override
  void initState() {
    super.initState();
    fetchMedia(); // Fetch media when the screen initializes
  }

  void fetchMedia() async {
    // Using Dio to perform a GET request

    try {
      var response = await DioService().dio.get(
          'https://electronicmindofalzheimerpatients.azurewebsites.net/Patient/GetMedia');
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
                    child: mediaItem.type == MediaType.image
                        ? Image.network(mediaItem.path, fit: BoxFit.cover)
                        : const DecoratedBox(
                            decoration: BoxDecoration(
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
    );
  }
}
