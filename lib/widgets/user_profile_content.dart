import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:truecinema/widgets/editable_field.dart';
import 'package:truecinema/widgets/profile_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:truecinema/theme/theme_notifier.dart';
import 'package:truecinema/screens/login_screen.dart'; 

class UserProfileContent extends StatefulWidget {
  const UserProfileContent({super.key});

  @override
  State<UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends State<UserProfileContent> {
  final user = FirebaseAuth.instance.currentUser!;
  late DocumentReference<Map<String, dynamic>> userDoc;

  // Método para cerrar sesión
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

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
              Align(
                alignment: Alignment.topRight,
                child: Consumer<ThemeNotifier>(
                  builder: (context, themeNotifier, _) {
                    return IconButton(
                      icon: Icon(
                        themeNotifier.isDarkMode 
                            ? Icons.dark_mode 
                            : Icons.light_mode,
                        color: Theme.of(context).appBarTheme.iconTheme?.color,
                      ),
                      onPressed: () {
                        themeNotifier.toggleTheme();
                      },
                    );
                  },
                ),
              ),
              ProfileImageWidget(
                googlePhotoUrl: FirebaseAuth.instance.currentUser?.photoURL,
              ),
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

              // Botón de cerrar sesión
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _signOut(context),
              ),
            ],
          ),
        );
      },
    );
  }
}