import 'package:vv/models/media_item.dart';

class MediaItempatient {
  final String path;
  final String description;
  final MediaType type;
  final bool isNetwork;
  final String uploadedDate; // New field for upload date
  final String uploaderFamilyName; // New field for uploader's family name

  MediaItempatient({
    required this.path,
    required this.description,
    required this.type,
    required this.isNetwork,
    required this.uploadedDate,
    required this.uploaderFamilyName,
  });
}

enum MediaTypepatient { image, video }
