import 'dart:io';
import 'package:http_parser/http_parser.dart' as http;
import 'package:dio/dio.dart';
import 'package:vv/api/login_api.dart';

import 'package:vv/models/media_item.dart';

class MediaService {
  Future<bool> uploadFile(
      String filePath, String description, MediaType type) async {
    String url =
        "https://electronicmindofalzheimerpatients.azurewebsites.net/api/Family/UploadMedia";
    String fileName = filePath.split('/').last;
    String fileExtension = fileName
        .split('.')
        .last; // Ensure the extension is in lower case for comparison

    // Use the aliased http.MediaType for content type
    http.MediaType? contentType;
    if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
      contentType = http.MediaType('image', fileExtension);
    } else if (['mp4', 'avi'].contains(fileExtension)) {
      // Add other video formats as needed
      contentType = http.MediaType('video', fileExtension);
    }

    var formData = FormData.fromMap({
      "MediaFile": await MultipartFile.fromFile(filePath,
          filename: fileName, contentType: contentType),
      "Caption": description,
    });

    try {
      Response response = await DioService().dio.post(url, data: formData);
      if (response.statusCode == 200) {
        print('done');
        return true; // Upload successful
      } else {
        return false; // Upload failed
      }
    } catch (e) {
      // Handle any exceptions
      print("Upload failed with exception: $e");
      return false; // Indicate failure due to exception
    }
  }
}
