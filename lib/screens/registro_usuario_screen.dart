import 'package:flutter/material.dart';
import 'package:truecinema/services/firebase_services.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final correoController = TextEditingController();
  final contrasenaController = TextEditingController();
  bool adminValue = false;

  void registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      await db.collection('usuarios').add({
        'nombre': nombreController.text.trim(),
        'apellidos': apellidosController.text.trim(),
        'correo': correoController.text.trim(),
        'contraseña': contrasenaController.text.trim(),
        'administrador': adminValue,
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Usuario')),
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
              TextFormField(
                controller: contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
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
                onPressed: registrarUsuario,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
