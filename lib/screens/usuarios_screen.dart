import 'package:flutter/material.dart';
import 'package:truecinema/screens/editar_usuario_screen.dart';
import 'package:truecinema/screens/registro_usuario_screen.dart';
import 'package:truecinema/services/firebase_services.dart';

enum FiltroUsuario { todos, administradores, usuariosNormales }

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List usuarios = [];
  List usuariosFiltrados = [];
  String busqueda = '';
  FiltroUsuario filtroSeleccionado = FiltroUsuario.todos;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  void cargarUsuarios() async {
    List usuariosObtenidos = await getTodosLosUsuarios();
    setState(() {
      usuarios = usuariosObtenidos;
      aplicarFiltros();
    });
  }

  void aplicarFiltros() {
    List filtrados = usuarios.where((usuario) {
      // Convertir campo administrador a bool
      bool esAdmin = false;
      final adminValue = usuario['administrador'];
      if (adminValue is bool) {
        esAdmin = adminValue;
      } else if (adminValue is String) {
        esAdmin = adminValue.toLowerCase() == 'true';
      } else if (adminValue is int) {
        esAdmin = adminValue == 1;
      }

      // Filtrar según filtroSeleccionado
      if (filtroSeleccionado == FiltroUsuario.administradores && !esAdmin) {
        return false;
      }
      if (filtroSeleccionado == FiltroUsuario.usuariosNormales && esAdmin) {
        return false;
      }

      // Filtrar según búsqueda
      if (busqueda.isNotEmpty) {
        final nombreCompleto =
            '${usuario['nombre']} ${usuario['apellidos']}'.toLowerCase();
        if (!nombreCompleto.contains(busqueda.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    setState(() {
      usuariosFiltrados = filtrados;
    });
  }

  void filtrarUsuarios(String valor) {
    busqueda = valor.toLowerCase();
    aplicarFiltros();
  }

  void cambiarFiltro(FiltroUsuario filtro) {
    filtroSeleccionado = filtro;
    aplicarFiltros();
  }

  void mostrarCrudUsuario(Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modificar usuario'),
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
            child: Row(
              children: [
                // Campo de búsqueda expandido
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o apellidos',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: filtrarUsuarios,
                  ),
                ),
                const SizedBox(width: 8),
                // Botón para filtro desplegable
                PopupMenuButton<FiltroUsuario>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtrar usuarios',
                  onSelected: cambiarFiltro,
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: FiltroUsuario.todos,
                      child: Row(
                        children: [
                          const Icon(Icons.list),
                          const SizedBox(width: 8),
                          Text('Todos'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FiltroUsuario.administradores,
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text('Administradores'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FiltroUsuario.usuariosNormales,
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text('Usuarios normales'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: usuariosFiltrados.isEmpty
                ? const Center(child: Text('No hay usuarios'))
                : ListView.builder(
                    itemCount: usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      final usuario = usuariosFiltrados[index];
                      // Comprobar si es admin para mostrar estrella
                      bool esAdmin = false;
                      final adminValue = usuario['administrador'];
                      if (adminValue is bool) {
                        esAdmin = adminValue;
                      } else if (adminValue is String) {
                        esAdmin = adminValue.toLowerCase() == 'true';
                      } else if (adminValue is int) {
                        esAdmin = adminValue == 1;
                      }

                      return ListTile(
                        title: Row(
                          children: [
                            Text('${usuario['nombre']} ${usuario['apellidos']}'),
                            if (esAdmin) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                            ],
                          ],
                        ),
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
