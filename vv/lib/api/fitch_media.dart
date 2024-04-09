import 'package:flutter/material.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/models/media_item.dart'; // Your MediaItem model
import 'package:vv/page/full_screen_viewer.dart';
// Path to your FullScreenViewer widget

// Function to fetch media data and navigate to FullScreenViewer
Future<void> fetchAndShowMedia(BuildContext context) async {
  try {
    var response = await DioService().dio.get(
        'https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/GetMediaForFamily');
    var data = response.data;

    MediaItem mediaItem = MediaItem(
      path: data[
          'mediaUrl'], // Assuming 'mediaUrl' is the key for the media URL in your response
      description: data[
          'caption'], // Assuming 'caption' is the key for the caption in your response
      type:
          data['mediaExtension'] == '.mp4' ? MediaType.video : MediaType.image,
      isNetwork: true, // Since we're fetching from a network
    );

    // Navigate to FullScreenViewer with the fetched MediaItem
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullScreenViewer(mediaItem: mediaItem),
    ));
  } catch (e) {
    print('Failed to fetch media: $e');
  }
}
