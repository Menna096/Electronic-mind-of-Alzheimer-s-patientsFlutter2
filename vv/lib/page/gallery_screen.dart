import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/page/description_screen.dart';
import 'package:vv/page/full_screen_viewer.dart';
import 'package:vv/widgets/background.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<MediaItem> mediaItems = [];

  @override
  void initState() {
    super.initState();
    fetchMedia(); // Fetch media when the screen initializes
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
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
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
      appBar: AppBar(title: Text('Pictures and Videos')),
      body: Background(
        SingleChildScrollView: null,
        child: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
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
                        : DecoratedBox(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedia,
        child: Icon(Icons.add),
      ),
    );
  }
}
