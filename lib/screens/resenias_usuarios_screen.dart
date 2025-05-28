import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:truecinema/models/resenia.dart';
class ReseniasUsuarioScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ReseniasUsuarioScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ReseniasUsuarioScreen> createState() => _ReseniasUsuarioScreenState();
}

class _ReseniasUsuarioScreenState extends State<ReseniasUsuarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<bool> _deleteResenia(String reseniaId) async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Reseñas de ${widget.userName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar reseñas...',
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
                  .where('userId', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron reseñas'),
                  );
                }
                
                List<Resenia> resenias = snapshot.data!.docs
                    .map((doc) => Resenia.fromFirestore(doc))
                    .where((resenia) => 
                        resenia.movieTitle.toLowerCase().contains(_searchQuery) ||
                        resenia.comment.toLowerCase().contains(_searchQuery))
                    .toList();

                if (resenias.isEmpty) {
                  return const Center(
                    child: Text('No hay reseñas que coincidan con la búsqueda'),
                  );
                }

                return ListView.builder(
                  itemCount: resenias.length,
                  itemBuilder: (context, index) {
                    final resenia = resenias[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(
                          resenia.movieTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text('${resenia.rating}/10'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              resenia.comment,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteResenia(resenia.id);
                          },
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