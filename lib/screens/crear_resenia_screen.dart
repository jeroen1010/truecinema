import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class CrearReseniaScreen extends StatefulWidget {
  final Movie movie;

  const CrearReseniaScreen({super.key, required this.movie});

  @override
  _CrearReseniaScreenState createState() => _CrearReseniaScreenState();
}

class _CrearReseniaScreenState extends State<CrearReseniaScreen> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  String _nombreCompleto = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final nombre = data['nombre'] ?? '';
        final apellidos = data['apellidos'] ?? '';
        
        setState(() {
          _nombreCompleto = nombre.isNotEmpty || apellidos.isNotEmpty 
              ? '$nombre $apellidos'.trim()
              : 'Anónimo';
        });
      } else {
        setState(() => _nombreCompleto = 'Anónimo');
      }
    } catch (e) {
      setState(() => _nombreCompleto = 'Anónimo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseña de ${widget.movie.title}'),
        elevation: 2,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Publicando como: $_nombreCompleto',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Valoración (1-10):',
                      style: TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _rating,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _rating.round().toString(),
                      activeColor: Colors.amber,
                      inactiveColor: Colors.grey[300],
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    Center(
                      child: Text(
                        '${_rating.round()}/10',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 5,
                      minLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Escribe tu reseña',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor escribe tu reseña';
                        }
                        if (value.length < 10) {
                          return 'La reseña debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Publicar Reseña'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30, 
                            vertical: 15
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _submitResenia,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Future<void> _submitResenia() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final reseniaRef = FirebaseFirestore.instance.collection('resenias').doc();

        await reseniaRef.set({
          'id': reseniaRef.id,
          'movieId': widget.movie.id.toString(),
          'userId': user.uid,
          'userName': _nombreCompleto,
          'movieTitle': widget.movie.title,
          'rating': _rating.round(),
          'comment': _commentController.text,
          'timestamp': DateTime.now(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reseña publicada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}