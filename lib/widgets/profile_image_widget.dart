/*import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageWidget extends StatefulWidget {
  final String? initialUrl;
  final String? googlePhotoUrl;
  final Function(String url) onImageChanged;

  const ProfileImageWidget({
    super.key,
    required this.initialUrl,
    required this.googlePhotoUrl,
    required this.onImageChanged,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? imageUrl;

  @override
  void initState() {
    imageUrl = widget.initialUrl ?? widget.googlePhotoUrl;
    super.initState();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${picked.name}');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      widget.onImageChanged(url);
      setState(() {
        imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: pickImage,
          ),
        ),
      ],
    );
  }
}*/
