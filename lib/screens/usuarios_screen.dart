import 'package:flutter/material.dart';
import 'package:truecinema/screens/editar_usuario_screen.dart';
import 'package:truecinema/screens/registro_usuario_screen.dart';
import 'package:truecinema/services/firebase_services.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List usuarios = [];
  List usuariosFiltrados = [];
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  void cargarUsuarios() async {
    List usuariosObtenidos = await getTodosLosUsuarios();
    setState(() {
      usuarios = usuariosObtenidos;
      usuariosFiltrados = usuariosObtenidos;
    });
  }

  void filtrarUsuarios(String valor) {
    setState(() {
      busqueda = valor.toLowerCase();
      usuariosFiltrados = usuarios.where((usuario) {
        final nombreCompleto = '${usuario['nombre']} ${usuario['apellidos']}'.toLowerCase();
        return nombreCompleto.contains(busqueda);
      }).toList();
    });
  }

  void mostrarCrudUsuario(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modificar usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarUsuarioScreen(usuario: usuario),
                      ),
                    ).then((resultado) {
                      if (resultado == true) {
                        cargarUsuarios();
                      }
                    });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  await eliminarUsuario(usuario['uid']);
                  cargarUsuarios();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void navegarARegistroUsuario() {
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroUsuarioScreen(),
      ),
      ).then((resultado) {
        if (resultado == true) {
          cargarUsuarios();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios Registrados')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o apellidos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filtrarUsuarios,
            ),
          ),
          Expanded(
            child: usuariosFiltrados.isEmpty
                ? const Center(child: Text('No hay usuarios'))
                : ListView.builder(
                    itemCount: usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      final usuario = usuariosFiltrados[index];
                      return ListTile(
                        title: Text('${usuario['nombre']} ${usuario['apellidos']}'),
                        subtitle: Text(usuario['correo']),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => mostrarCrudUsuario(usuario),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text('Añadir Usuario'),
          onPressed: navegarARegistroUsuario,
        ),
      ),
    );
  }
}
