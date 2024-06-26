import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vv/Patient/mainpagepatient/fullscreenMedia.dart';
import 'package:vv/Patient/mainpagepatient/mainpatient.dart';
import 'package:vv/api/login_api.dart'; // Ensure this import has the necessary DioService setup
import 'package:vv/models/media_patient.dart';
import 'package:vv/widgets/background.dart';
import 'package:vv/models/media_item.dart'; // Importing the modified MediaItem model

class GalleryScreenPatient extends StatefulWidget {
  const GalleryScreenPatient({super.key});

  @override
  _GalleryScreenPatientState createState() => _GalleryScreenPatientState();
}

class _GalleryScreenPatientState extends State<GalleryScreenPatient> {
  List<MediaItempatient> mediaItems = [];

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  @override
  void dispose() {
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
                uploadedDate: item['uploaded_date'],
                uploaderFamilyName: item['familyNameWhoUpload'],
              ))
          .toList();
      setState(() {
        mediaItems = fetchedItems;
      });
    } catch (e) {
      print('Failed to fetch media: $e');
    }
  }

  void _viewMediaItem(MediaItempatient item) {
    showDialog(
      context: context,
      builder: (_) => FullScreenViewerpatient(mediaItem: item),
    );
  }

  String formatDateString(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return dateString;
    }
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
              MaterialPageRoute(builder: (context) => const mainpatient()),
            );
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
        child: Padding(
          padding:
              const EdgeInsets.all(8.0), // Adjusted padding for better spacing
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // Changed to 2 for larger images
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: mediaItems.length,
            itemBuilder: (context, index) {
              var mediaItem = mediaItems[index];
              return CustomCard(
                child: InkWell(
                  onTap: () => _viewMediaItem(mediaItem),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: mediaItem.type == MediaType.image
                                  ? Image.network(
                                      mediaItem.path,
                                      fit: BoxFit.cover,
                                      width: double
                                          .infinity, // Ensures the image covers the width
                                      height: double
                                          .infinity, // Ensures the image covers the height
                                    )
                                  : Image.network(
                                      mediaItem.path,
                                      fit: BoxFit.cover,
                                      width: double
                                          .infinity, // Ensures the video thumbnail covers the width
                                      height: double
                                          .infinity, // Ensures the video thumbnail covers the height
                                    ),
                            ),
                            if (mediaItem.type == MediaType.video)
                              const Icon(Icons.play_circle_outline,
                                  size: 40, color: Colors.white),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Adjusted padding for better spacing
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mediaItem.description,
                              style: const TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 54, 96, 196),
                                  fontFamily: 'ConcertOne'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              ' ${tr('uploaded_on')} ${formatDateString(mediaItem.uploadedDate)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 80, 80, 80),
                                  fontFamily: 'Outfit'),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              tr('byLabel', args: [mediaItem.uploaderFamilyName]),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;

  const CustomCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Center(child: child),
      ),
    );
  }
}
