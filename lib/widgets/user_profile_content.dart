import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truecinema/widgets/editable_field.dart';
import 'package:truecinema/widgets/profile_image_widget.dart';

class UserProfileContent extends StatefulWidget {
  const UserProfileContent({super.key});

  @override
  State<UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends State<UserProfileContent> {
  final user = FirebaseAuth.instance.currentUser!;
  late DocumentReference<Map<String, dynamic>> userDoc;

  @override
  void initState() {
    super.initState();
    userDoc = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: userDoc.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
             /* ProfileImageWidget(
                initialUrl: userData['fotoPerfil'],
                googlePhotoUrl: user.photoURL,
                onImageChanged: (url) => userDoc.update({'fotoPerfil': url}),
              ),*/
              const SizedBox(height: 24),
              EditableField(
                label: 'Nombre',
                initialValue: userData['nombre'] ?? '',
                onSave: (value) => userDoc.update({'nombre': value}),
              ),
              EditableField(
                label: 'Apellidos',
                initialValue: userData['apellidos'] ?? '',
                onSave: (value) => userDoc.update({'apellidos': value}),
              ),
              EditableField(
                label: 'Sobre mí',
                initialValue: userData['descripcion'] ?? '',
                maxLines: 4,
                onSave: (value) => userDoc.update({'descripcion': value}),
              ),
            ],
          ),
        );
      },
    );
  }
}
