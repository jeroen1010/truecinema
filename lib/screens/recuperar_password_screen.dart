import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecuperarPasswordScreen extends StatelessWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: _RecuperarPassword(),
        ),
      ),
    );
  }
}

class _RecuperarPassword extends StatefulWidget {
  const _RecuperarPassword();

  @override
  State<_RecuperarPassword> createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<_RecuperarPassword> {
  final TextEditingController _emailController = TextEditingController();

  String? _correoError;

  bool _emailSent = false;

  Future<void> _enviarCorreoRestablecimiento() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _correoError = 'Por favor, ingresa tu correo electrónico.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      setState(() => _emailSent = true);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correo enviado'),
          content: const Text(
              'Se ha enviado un correo con un enlace para restablecer tu contraseña.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error al enviar el correo: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.password,
            size: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            "Cambio de contraseña",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 220),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: _emailController,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              enabled: !_emailSent,
              decoration: InputDecoration(
                hintText: 'Correo',
                suffixIcon: const Icon(Icons.email),
                errorText: _correoError,
              ),
              onChanged: (value) {
                setState(() {
                  _correoError = null;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _emailSent ? null : _enviarCorreoRestablecimiento,
            child: const Text('Enviar correo para restablecer contraseña'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}