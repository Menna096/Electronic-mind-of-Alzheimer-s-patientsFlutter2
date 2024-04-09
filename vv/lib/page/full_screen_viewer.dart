import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/widgets/background.dart';

class FullScreenViewer extends StatefulWidget {
  final MediaItem mediaItem;

  FullScreenViewer({required this.mediaItem});

  @override
  _FullScreenViewerState createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
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
            ],
          ),
        ),
      ),
    );
  }
}
