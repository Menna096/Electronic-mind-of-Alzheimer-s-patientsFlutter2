import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/Patient/mainpagepatient/fullscreenMedia.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart'; // Ensure this import has the necessary DioService setup
import 'package:vv/models/media_patient.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/models/media_item.dart'; // Importing the modified MediaItem model

class GalleryScreenPatient extends StatefulWidget {
  @override
  _GalleryScreenPatientState createState() => _GalleryScreenPatientState();
}

class _GalleryScreenPatientState extends State<GalleryScreenPatient> {
  List<MediaItempatient> mediaItems = [];

  @override
  void initState() {
    super.initState();
    fetchMedia(); // Initiating media fetching on state initialization
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
