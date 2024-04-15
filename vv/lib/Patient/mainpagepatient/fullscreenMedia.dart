import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/models/media_patient.dart';
import 'package:vv/widgets/background.dart';

class FullScreenViewerpatient extends StatefulWidget {
  final MediaItempatient mediaItem;

  FullScreenViewerpatient({required this.mediaItem});

  @override
  _FullScreenViewerpatientState createState() =>
      _FullScreenViewerpatientState();
}

class _FullScreenViewerpatientState extends State<FullScreenViewerpatient> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.mediaItem.type == MediaType.video &&
        widget.mediaItem.isNetwork) {
      _controller = VideoPlayerController.network(widget.mediaItem.path)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
      appBar: AppBar(),
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.mediaItem.type == MediaType.image)
                widget.mediaItem.isNetwork
                    ? Image.network(widget.mediaItem.path)
                    : Image.file(File(widget.mediaItem.path)),
              if (widget.mediaItem.type == MediaType.video)
                _controller != null && _controller!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    : CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.mediaItem.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "Uploaded on: ${formatDateString(widget.mediaItem.uploadedDate)}", // Formatted date
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Uploaded by: ${widget.mediaItem.uploaderFamilyName}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
