import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vv/api/dio_ser.dart';
import 'package:vv/models/media_item.dart';
import 'package:vv/widgets/background.dart';

class DescriptionScreen extends StatefulWidget {
  final String mediaPath;
  final MediaType type;

  const DescriptionScreen(
      {super.key, required this.mediaPath, required this.type});

  @override
  _DescriptionScreenState createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMedia() async {
    MediaService mediaService = MediaService();
    bool uploadSuccessful = await mediaService.uploadFile(
        widget.mediaPath, _descriptionController.text, widget.type);

    if (uploadSuccessful) {
      // Create a new MediaItem with the provided path, description, and type
      final newMediaItem = MediaItem(
        path: widget.mediaPath,
        description: _descriptionController.text,
        type: widget.type,
      );

      // Return to the previous screen with the new media item
      Navigator.pop(context, newMediaItem);
    } else {
      // Handle upload failure (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text('Add picture or video'.tr())),
      resizeToAvoidBottomInset:
          true, // Ensures the UI adjusts when the keyboard is open
      body: Background(
        SingleChildScrollView: null,
        child: SingleChildScrollView(
          // Make the screen scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 100,
                  backgroundImage: FileImage(File(widget.mediaPath)),
                  child: widget.type == MediaType.video
                      ? const Icon(Icons.play_circle_fill, size: 100)
                      : null,
                ),
                const SizedBox(height: 20),
                 Text(
                    'Enter a simple description about the picture/video'.tr()),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _descriptionController,
                    decoration:  InputDecoration(
                      hintText: 'Description'.tr(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveMedia,
                  child:  Text('Save'.tr()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:  Text('Cancel'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
