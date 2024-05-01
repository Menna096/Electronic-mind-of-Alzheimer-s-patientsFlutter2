import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:chewie/chewie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:video_player/video_player.dart';
import 'package:vv/api/login_api.dart';
import 'package:vv/utils/token_manage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailScreenSecret extends StatefulWidget {
  final String url;
  final String fileType;

  DetailScreenSecret({required this.url, required this.fileType});

  @override
  _DetailScreenSecretState createState() => _DetailScreenSecretState();
}

class _DetailScreenSecretState extends State<DetailScreenSecret> {
  ChewieController? _chewieController; // Make it nullable
  VideoPlayerController? _videoPlayerController;
 
  @override
  void initState() {
    super.initState();
    if (widget.fileType == '.mp4') {
      initializeVideoPlayer();
      
    }
  }

  

  void initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Only set the _chewieController if the widget is still mounted
        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              autoPlay: true,
              looping: true,
            );
          });
        }
      });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose(); // Dispose if it's initialized
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.fileType == '.mp4' &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      content = Chewie(
          controller: _chewieController!); // Ensure it's initialized before use
    } else if (widget.fileType == '.pdf') {
      content = PDFView(
        filePath: widget.url,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        swipeHorizontal: true,
        nightMode: false,
      );
    } else if (widget.fileType == '.txt') {
      content = FutureBuilder<String>(
        future: fetchFileContent(widget.url),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Text(snapshot.data!),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return CircularProgressIndicator();
        },
      );
    } else {
      content = Image.network(widget.url);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail View'),
      ),
      body: content,
    );
  }

  Future<String> fetchFileContent(String url) async {
    // Use Dio or HttpClient to fetch the text content from the given URL
    final response = await DioService().dio.get(url);
    if (response.statusCode == 200) {
      return response.data.toString();
    } else {
      throw Exception('Failed to load file content');
    }
  }

  Future<String> downloadFile(String url, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await DioService().dio.download(url, file.path);
    return file.path;
  }
}