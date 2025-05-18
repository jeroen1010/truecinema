import 'package:flutter/material.dart';
import 'package:truecinema/services/firebase_services.dart';

class EditarUsuarioScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarUsuarioScreen({super.key, required this.usuario});

  @override
  State<EditarUsuarioScreen> createState() => _EditarUsuarioScreenState();
}

class _EditarUsuarioScreenState extends State<EditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nombreController;
  late TextEditingController apellidosController;
  late TextEditingController correoController;
  late bool adminValue;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.usuario['nombre']);
    apellidosController = TextEditingController(text: widget.usuario['apellidos']);
    correoController = TextEditingController(text: widget.usuario['correo']);
    adminValue = widget.usuario['administrador'] ?? false;
  }

  void guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      await db.collection('usuarios').doc(widget.usuario['uid']).update({
        'nombre': nombreController.text.trim(),
        'apellidos': apellidosController.text.trim(),
        'correo': correoController.text.trim(),
        'administrador': adminValue,
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: apellidosController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) => value!.contains('@') ? null : 'Correo inválido',
              ),
              DropdownButtonFormField<bool>(
                value: adminValue,
                decoration: const InputDecoration(labelText: 'Administrador'),
                items: const [
                  DropdownMenuItem(
                    value: true,
                    child: Text('Sí'),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text('No'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    adminValue = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: guardarCambios,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
