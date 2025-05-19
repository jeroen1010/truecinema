import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:truecinema/screens/screens.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: _Formulario(),
        ),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario();

  @override
  __FormularioState createState() => __FormularioState();
}

class __FormularioState extends State<_Formulario> {
  final _formKey = GlobalKey<FormState>();
  String? _emailError;
  String? _passwordError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool isSigningIn = false;
  bool _obscureText = true;

  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (isSigningIn) return;

    setState(() {
      isSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          isSigningIn = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
            'nombre': googleUser.displayName ?? 'Usuario',
            'apellidos': '',
            'correo': googleUser.email,
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
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      print("Error durante el inicio de sesión con Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión con Google: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSigningIn = false;
      });
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSigningIn = true;
      });

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          final String uid = userCredential.user!.uid;

          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .get();

          if (userDoc.exists) {
            final bool isAdmin = userDoc['administrador'] ?? false;

            if (isAdmin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UsuariosScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again.';

        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email address.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password. Please try again.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is invalid.';
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
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isSigningIn = false;
        });
      }
    }
  }

  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        canCheckBiometrics = await _localAuth.isDeviceSupported();
      }

      if (canCheckBiometrics) {
        final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (availableBiometrics.isEmpty) {
          print("No hay credenciales biométricas configuradas.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay credenciales biométricas configuradas.')),
          );
        } else {
          print("Biométricos disponibles: $availableBiometrics");
        }
      } else {
        print("El dispositivo no soporta autenticación biométrica.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El dispositivo no soporta autenticación biométrica.')),
        );
      }
    } catch (e) {
      print("Error al verificar disponibilidad biométrica: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder a la aplicación',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación fallida')),
        );
      }
    } catch (e) {
      print("Error durante la autenticación: $e");
      String errorMessage = 'Error durante la autenticación.';

      if (e is PlatformException) {
        switch (e.code) {
          case 'NotAvailable':
            errorMessage = 'No hay credenciales biométricas configuradas.';
            break;
          case 'NotEnrolled':
            errorMessage = 'No hay huellas dactilares o reconocimiento facial configurado.';
            break;
          case 'LockedOut':
            errorMessage = 'Demasiados intentos fallidos. Inténtalo más tarde.';
            break;
          default:
            errorMessage = 'Error desconocido: ${e.message}';
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Image.asset(
            'assets/icono.png',
            height: 100,
          ),
          const SizedBox(height: 40),
          const Text(
            "Bienvenido a TrueCinema",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: _emailController,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Email',
                suffixIcon: const Icon(Icons.email),
                errorText: _emailError,
              ),
              focusNode: _emailFocusNode,
              onEditingComplete: () {
                setState(() {
                  _emailError = _validateEmail(_emailController.text);
                });
              },
              validator: (value) {
                return _validateEmail(value);
              },
            ),
          ),
          const SizedBox(height: 40),

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
          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSigningIn ? null : _signInWithEmailAndPassword,
                child: Text(isSigningIn ? 'Cargando...' : 'Iniciar sesión'),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSigningIn ? null : _signInWithGoogle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo_google.png',
                      height: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(isSigningIn ? 'Cargando...' : 'Iniciar sesión con Google'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes cuenta?"),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegistroScreen()),
                  ),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _authenticateWithBiometrics,
                  child: const Text("Usar huella dactilar"),
                ),
                TextButton(
                  child: const Text('Olvidé mi contraseña'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecuperarPasswordScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña.';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una letra mayúscula.';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'La contraseña debe contener al menos un carácter especial.';
    }

    return null;
  }
}