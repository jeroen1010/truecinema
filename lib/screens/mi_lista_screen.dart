import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truecinema/models/models.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/screens/screens.dart';
import 'package:truecinema/services/TMDBservice.dart';

class MiListaScreen extends StatelessWidget {
  const MiListaScreen({super.key});

  void _eliminarDeMiLista(BuildContext context, Movie movie) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final scaffoldContext = context;
    
    try {
      await FirebaseFirestore.instance
          .collection('mi_lista')
          .doc(user.uid)
          .collection('peliculas')
          .doc(movie.id.toString())
          .delete();

      if (!scaffoldContext.mounted) return;
      
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Película eliminada de Mi Lista')),
      );
    } catch (e) {
      if (!scaffoldContext.mounted) return;
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("No has iniciado sesión."));
    }

    final peliculasRef = FirebaseFirestore.instance
        .collection('mi_lista')
        .doc(user.uid)
        .collection('peliculas');

    return MainScaffold(
      estadoIndex: 3,
      title: 'Mi Lista',
      screen: Builder(
        builder: (builderContext) {
          return StreamBuilder<QuerySnapshot>(
            stream: peliculasRef.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No tienes películas guardadas."),
                );
              }

              final movies = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Movie(
                  id: data['id'],
                  title: data['title'],
                  posterUrl: data['posterUrl'],
                  overview: data['overview'],
                  voteAverage: (data['voteAverage'] as num).toDouble(),
                );
              }).toList();

              return ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('resenias')
                        .where('movieId', isEqualTo: movie.id.toString())
                        .snapshots(),
                    builder: (context, reseniasSnapshot) {
                      final reseniasCount = reseniasSnapshot.data?.docs.length ?? 0;
                      return MovieListItem(
                        movie: movie,
                        isSaved: true,
                        reseniasCount: reseniasCount, 
                        onTap: () async {
                          if (!builderContext.mounted) return;
                          try {
                            final actores = await TMDbApi().fetchMovieActors(movie.id);
                            if (!builderContext.mounted) return;
                            Navigator.push(
                              builderContext,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailsScreen(
                                  movie: movie,
                                  actors: actores,
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!builderContext.mounted) return;
                            ScaffoldMessenger.of(builderContext).showSnackBar(
                              SnackBar(content: Text('Error al cargar actores: $e')),
                            );
                          }
                        },
                        onGuardar: () {},
                        onEliminar: () => _eliminarDeMiLista(builderContext, movie),
                        onResenias: null,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}