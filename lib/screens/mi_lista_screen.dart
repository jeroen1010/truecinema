import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truecinema/models/movie.dart';
import 'package:truecinema/widgets/movie_list_item.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/screens/movie_details_screen.dart';
import 'package:truecinema/services/TMDBservice.dart';

class MiListaScreen extends StatelessWidget {
  const MiListaScreen({super.key});

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
      screen: StreamBuilder<QuerySnapshot>(
        stream: peliculasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tienes películas guardadas."));
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
              return MovieListItem(
                movie: movie,
                onTap: () async {
                  try {
                    final actores = await TMDbApi().fetchMovieActors(movie.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsScreen(
                          movie: movie,
                          actors: actores,
                        ),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al cargar actores: $e')),
                    );
                  }
                },
                onGuardar: () {}, // Ya está guardada, no hacemos nada aquí
                onResenias: null,
              );
            },
          );
        },
      ),
    );
  }
}
