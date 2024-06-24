import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class DetailScreenSecret extends StatefulWidget {
  final String url;
  final String fileType;

  const DetailScreenSecret({super.key, required this.url, required this.fileType});

  @override
  _DetailScreenSecretState createState() => _DetailScreenSecretState();
}

class _DetailScreenSecretState extends State<DetailScreenSecret> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  bool isLoading = true;

  final double _position = 100.0; // Example value for initial animation position

  @override
  void initState() {
    super.initState();
    if (widget.fileType == '.mp4') {
      initializeVideoPlayer();
    }

    // Simulate loading for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  void initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
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
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50), // Darker background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: const Text(
          "Detail View",
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
              bottom: Radius.circular(2.0),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color.fromARGB(255, 14, 89, 164)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            top: _position,
            left: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            bottom: -_position,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20.0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ContentWidget(
                          url: widget.url,
                          fileType: widget.fileType,
                          chewieController: _chewieController,
                          videoPlayerController: _videoPlayerController,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final String url;
  final String fileType;
  final ChewieController? chewieController;
  final VideoPlayerController? videoPlayerController;

  const ContentWidget({super.key, 
    required this.url,
    required this.fileType,
    this.chewieController,
    this.videoPlayerController,
  });

  @override
  Widget build(BuildContext context) {
    if (fileType == '.mp4' &&
        videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      return Chewie(controller: chewieController!);
    } else if (fileType == '.pdf') {
      return PDFView(
        filePath: url,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        swipeHorizontal: true,
        nightMode: false,
      );
    } else if (fileType == '.txt') {
      return FutureBuilder<String>(
        future: fetchFileContent(url),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  snapshot.data!,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    } else {
      // Default case: Display an image if fileType is not recognized
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Image.network(
          url,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Future<String> fetchFileContent(String url) async {
    // Example implementation, replace with your own logic to fetch text content
    await Future.delayed(const Duration(seconds: 2)); // Simulating a delay
    return 'Dummy text content from $url';
  }
}
