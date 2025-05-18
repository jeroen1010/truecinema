import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

/// Obtiene todos los usuarios registrados en la base de datos
Future<List<Map<String, dynamic>>> getTodosLosUsuarios() async {
  List<Map<String, dynamic>> usuarios = [];

  try {
    QuerySnapshot snapshot = await db.collection('usuarios').get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      usuarios.add({
        'uid': doc.id,
        'nombre': data['nombre'] ?? '',
        'apellidos': data['apellidos'] ?? '',
        'correo': data['correo'] ?? '',
        'administrador': data['administrador'] ?? false,
        'contraseña': data['contraseña'] ?? ''
      });
    }
  } catch (e) {
    print("Error al obtener usuarios: $e");
  }

  return usuarios;
}

/// Elimina un usuario por ID
Future<void> eliminarUsuario(String uid) async {
  try {
    await db.collection('usuarios').doc(uid).delete();
  } catch (e) {
    print("Error al eliminar usuario: $e");
  }
}

/// Crea un nuevo usuario en la base de datos
Future<void> crearUsuario(Map<String, dynamic> usuario) async {
  try {
    await db.collection('usuarios').add({
      'nombre': usuario['nombre'],
      'apellidos': usuario['apellidos'],
      'correo': usuario['correo'],
      'administrador': usuario['administrador'] ?? false,
      'contraseña': usuario['contraseña'],
    });
  } catch (e) {
    print("Error al crear usuario: $e");
  }
}

/// Modifica los datos de un usuario existente por ID
Future<void> modificarUsuario(String uid, Map<String, dynamic> nuevosDatos) async {
  try {
    await db.collection('usuarios').doc(uid).update({
      'nombre': nuevosDatos['nombre'],
      'apellidos': nuevosDatos['apellidos'],
      'correo': nuevosDatos['correo'],
      'administrador': nuevosDatos['administrador'] ?? false,
      'contraseña': nuevosDatos['contraseña'],
    });
  } catch (e) {
    print("Error al modificar usuario: $e");
  }
}
