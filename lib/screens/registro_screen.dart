import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: _FormularioRegistro(),
        ),
      ),
    );
  }
}

class _FormularioRegistro extends StatefulWidget {
  const _FormularioRegistro();

  @override
  State<_FormularioRegistro> createState() => _FormularioRegistroState();
}

class _FormularioRegistroState extends State<_FormularioRegistro> {
  final _formKey = GlobalKey<FormState>();
  bool _sliderEnabled = false;
  String? _correoError;
  String? _passwordError;

  bool _obscureText = true;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _correoFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    _correoFocusNode.addListener(() {
      if (!_correoFocusNode.hasFocus) {
        setState(() {
          _correoError = _validarcorreo(_correoController.text);
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError = _validarPassword(_passwordController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _correoFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isButtonEnabled() {
    return _nombreController.text.isNotEmpty &&
        _apellidosController.text.isNotEmpty &&
        _correoController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _sliderEnabled &&
        _correoError == null &&
        _passwordError == null;
  }

  String? _validarcorreo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu correo electrónico.';
    }
    if (value.length < 6) {
      return 'El correo debe tener al menos 6 caracteres.';
    }
    if (!value.contains('@')) {
      return 'El correo debe contener un "@".';
    }

    final parts = value.split('@');
    if (parts.length != 2) {
      return 'El correo debe contener un "@".';
    }

    final domainPart = parts[1];
    if (!domainPart.contains('.')) {
      return 'El correo debe contener un "." después del "@".';
    }

    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña.';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una letra mayúscula.';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>-]'))) {
      return 'La contraseña debe contener al menos un carácter especial.';
    }

    return null;
  }

  Future<void> _registrarUsuario() async {
    if (!_isButtonEnabled()) return;

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _correoController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nombre': _nombreController.text.trim(),
          'apellidos': _apellidosController.text.trim(),
          'correo': _correoController.text.trim(),
          'contraseña': _passwordController.text.trim(),
          'administrador': false,
          'huella_dactilar_vinculada': false,
        });

        bool linkFingerprint = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Vincular huella dactilar?'),
            content: const Text(
                '¿Deseas vincular tu huella dactilar para un inicio de sesión más rápido?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );

        if (linkFingerprint) {
          bool authenticated = await _localAuth.authenticate(
            localizedReason:
                'Autentícate con tu huella dactilar para vincularla a tu cuenta',
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
            ),
          );

          if (authenticated) {
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .update({
              'huella_dactilar_vinculada': true,
            });

            print("Huella dactilar vinculada al usuario.");
          } else {
            print("Autenticación biométrica fallida.");
          }
        } else {
          print("El usuario no desea vincular su huella dactilar.");
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registro exitoso'),
            content: const Text('Tu cuenta ha sido creada correctamente.'),
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
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error durante el registro.';
      if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo electrónico ya está en uso.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.account_box,
            size: 100,
          ),
          const SizedBox(height: 40),
          const Text(
            "Regístrate a TrueCinema",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: _nombreController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              obscureText: false,
              decoration: const InputDecoration(
                hintText: "Nombre",
                suffixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: _apellidosController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              obscureText: false,
              decoration: const InputDecoration(
                hintText: "Apellidos",
                suffixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: _correoController,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Correo',
                suffixIcon: const Icon(Icons.email),
                errorText: _correoError,
              ),
              focusNode: _correoFocusNode,
              onChanged: (value) {
                setState(() {
                  _correoError = _validarcorreo(value);
                });
              },
              validator: (value) {
                return _validarcorreo(value);
              },
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: _passwordController,
              autocorrect: false,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                errorText: _passwordError,
              ),
              focusNode: _passwordFocusNode,
              onChanged: (value) {
                setState(() {
                  _passwordError = _validarPassword(value);
                });
              },
              validator: (value) {
                return _validarPassword(value);
              },
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _sliderEnabled,
                onChanged: (value) {
                  setState(() {
                    _sliderEnabled = value ?? false;
                  });
                },
              ),
              const Text('Aceptar los términos y condiciones')
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled() ? _registrarUsuario : null,
                child: const Text('Registrarse'),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿Ya tienes una cuenta?"),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Inicia sesión'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}