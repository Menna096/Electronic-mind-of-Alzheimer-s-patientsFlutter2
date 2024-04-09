class MediaItem {
  final String path; // This can be a local path or a URL, based on isNetwork
  final String description;
  final MediaType type;
  final bool
      isNetwork; // Added field to indicate whether the media is from the network

  MediaItem({
    required this.path,
    this.description = '',
    required this.type,
    this.isNetwork = false, // Assume local file by default
  });
}

enum MediaType { image, video }
