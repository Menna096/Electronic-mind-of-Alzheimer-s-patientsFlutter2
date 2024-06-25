import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vv/Family/mainpagefamily/mainpagefamily.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/page/description_screen.dart';
import 'package:vv/page/full_screen_viewer.dart';
import 'package:vv/widgets/background.dart';
import 'package:video_player/video_player.dart';
import 'dart:io'; // Import for File class

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<MediaItem> mediaItems = [];

  @override
  void initState() {
    super.initState();
    fetchMedia();
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
              title:  Text('Camera'.tr()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Gallery'.tr()),
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
              title: Text('Choose Media Type'.tr()),
              content: Text('What do you want to take?'.tr()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Photo'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:  Text('Video'.tr()),
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
     appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPageFamily()),
            ); // Go back to the previous page
          },
        ),
        title: Text(
          "Pictures and Videos".tr(),
          style: TextStyle(
            fontFamily: 'LilitaOne',
            fontSize: 23,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A95E9), Color(0xFF38A4C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(66, 55, 134, 190),
                offset: Offset(0, 10),
                blurRadius: 10.0,
              ),
            ],
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(50.0),
          ),
        ),
      ),
      body: Background(
        SingleChildScrollView: null,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1),
          itemCount: mediaItems.length,
          itemBuilder: (context, index) {
            var mediaItem = mediaItems[index];
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => _viewMediaItem(mediaItem),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: mediaItem.isNetwork ? 
                        // Network image
                        mediaItem.type == MediaType.image 
                            ? Image.network(mediaItem.path, fit: BoxFit.cover)
                            : const DecoratedBox(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'images/vid.png'), 
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.play_circle_outline,
                                      size: 50, color: Colors.white),
                                ),
                              ) 
                        : 
                        // Local image or video
                        mediaItem.type == MediaType.image
                            ? Image.file(File(mediaItem.path), fit: BoxFit.cover)
                            : VideoPlayerWidget(filePath: mediaItem.path), 
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

// Widget for playing local videos (using the video_player package)
class VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  const VideoPlayerWidget({super.key, required this.filePath});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {}); 
      });
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}