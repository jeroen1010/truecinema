import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageWidget extends StatefulWidget {
  final String? googlePhotoUrl; // Si tienes foto de Google, opcional

  const ProfileImageWidget({
    super.key,
    this.googlePhotoUrl,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? base64Image;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadImageFromFirestore();
  }

  Future<void> _loadImageFromFirestore() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        final fotoPerfil = doc.data()?['fotoPerfil'] as String?;
        if (fotoPerfil != null && fotoPerfil.isNotEmpty) {
          setState(() {
            base64Image = fotoPerfil;
          });
          return;
        }
      }

      // Si no hay fotoPerfil, usa la de Google si está
      if (widget.googlePhotoUrl != null) {
        // No es base64, es URL, para mostrar distinto
        setState(() {
          base64Image = null;
        });
      }
    } catch (e) {
      debugPrint('Error cargando foto perfil: $e');
    }
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await File(picked.path).readAsBytes();
      final base64Str = base64Encode(bytes);

      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('usuarios').doc(uid).update({
        'fotoPerfil': base64Str,
      });

      setState(() {
        base64Image = base64Str;
      });
    } catch (e) {
      debugPrint('Error al seleccionar/subir imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la foto de perfil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (base64Image != null) {
      try {
        // Imagen base64 de Firestore
        imageWidget = CircleAvatar(
          radius: 60,
          backgroundImage: MemoryImage(base64Decode(base64Image!)),
        );
      } catch (e) {
        // En caso de que no sea base64 válido, fallback
        imageWidget = CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(widget.googlePhotoUrl ?? ''),
        );
      }
    } else if (widget.googlePhotoUrl != null) {
      imageWidget = CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(widget.googlePhotoUrl!),
      );
    } else {
      imageWidget = const CircleAvatar(
        radius: 60,
        child: Icon(Icons.person, size: 60),
      );
    }

    return Stack(
      children: [
        imageWidget,
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: _pickAndSaveImage,
          ),
        ),
      ],
    );
  }
}
