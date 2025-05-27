import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truecinema/models/resenia.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/models/models.dart';

class ReseniasScreen extends StatefulWidget {
  const ReseniasScreen({super.key});

  @override
  State<ReseniasScreen> createState() => _ReseniasScreenState();
}

class _ReseniasScreenState extends State<ReseniasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<bool> _deleteResenia(String reseniaId, BuildContext context) async {
    bool confirmado = false;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de eliminar esta reseña?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                confirmado = true;
                Navigator.pop(context);
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmado) {
      await FirebaseFirestore.instance
          .collection('resenias')
          .doc(reseniaId)
          .delete();
    }

    return confirmado;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    
    return MainScaffold(
      estadoIndex: 2,
      title: 'Reseñas',
      screen: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por título de película...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('resenias')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                List<Resenia> resenias = snapshot.data!.docs
                    .map((doc) => Resenia.fromFirestore(doc))
                    .where((resenia) => 
                        resenia.movieTitle.toLowerCase().contains(_searchQuery))
                    .toList();

                if (resenias.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron reseñas'),
                  );
                }

                return ListView.builder(
                  itemCount: resenias.length,
                  itemBuilder: (context, index) {
                    final resenia = resenias[index];
                    return Dismissible(
                      key: Key(resenia.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) => _deleteResenia(resenia.id, context),
                      child: Card(
                        child: ListTile(
                          title: Text(resenia.movieTitle),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${resenia.rating}/10'),
                              Text(resenia.comment),
                              const SizedBox(height: 8),
                              Text(
                                'Por: ${resenia.userName}',
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteResenia(resenia.id, context);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}