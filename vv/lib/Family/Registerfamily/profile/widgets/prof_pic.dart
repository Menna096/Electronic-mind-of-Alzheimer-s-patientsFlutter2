import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vv/Family/Registerfamily/profile/screen/photo_screen.dart';
import 'package:vv/Family/Registerfamily/profile/widgets/choice_modal.dart';

class ProfilePicture extends StatefulWidget {
  final void Function(File?)? onImageSelected;

  const ProfilePicture({super.key, this.onImageSelected});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? _selectedImage;

  // Function to open up the bottom modal
  void _showModal () {
    showModalBottomSheet(
      context: context, 
      builder: (ctx) =>  ChoiceModal(
        selectedImage: _selectedImage,
        onImageSelect: (image) {
          setState(() {
            _selectedImage = image;
             widget.onImageSelected?.call(image);
          });
        },
        onImageDelete: () {
          setState(() {
            _selectedImage = null;
            widget.onImageSelected?.call(null);
          });
        },
      )
    );
  }

  // Function to view profile photo
  void _avatarSelect() {
    if( _selectedImage == null ) { return; } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PhotoScreen(
            profileImage: _selectedImage!
          )
        )
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Stack(
        children: [
          InkWell(
            onTap: _avatarSelect,
            child: CircleAvatar(
              backgroundImage: _selectedImage == null 
                // No profile picture image.
                ? const NetworkImage('https://rb.gy/wbc0ox') 
                // Profile picture image from camera or gallery.
                : FileImage(_selectedImage!) as ImageProvider<Object>?,
              radius: 95,
            ),
          ),
          // Icon Button to open the modal.
          Positioned(
            bottom: 0, right: 0,
            child: IconButton.filled(
              onPressed: _showModal, 
              icon: const Icon(Icons.camera_alt), 
              padding: const EdgeInsets.all(5),
            ),
          )
        ],
      ),
    );
  }
}
