import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truecinema/models/models.dart';
import 'package:truecinema/screens/screens.dart';
import 'package:truecinema/services/movie_service.dart';
import 'package:truecinema/widgets/widgets.dart';
import 'package:truecinema/services/TMDBservice.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = true;
  late Stream<QuerySnapshot> _savedMoviesStream;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _initSavedMoviesStream();
  }

  void _initSavedMoviesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _savedMoviesStream = FirebaseFirestore.instance
          .collection('mi_lista')
          .doc(user.uid)
          .collection('peliculas')
          .snapshots();
    } else {
      _savedMoviesStream = const Stream.empty();
    }
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await MovieService.fetchAllMovies();
      setState(() {
        _allMovies = movies;
        _filteredMovies = movies;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar películas: $e')),
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredMovies = _allMovies
          .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _guardarEnMiLista(Movie movie) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('mi_lista')
          .doc(user.uid)
          .collection('peliculas')
          .doc(movie.id.toString())
          .set({
        'id': movie.id,
        'title': movie.title,
        'posterUrl': movie.posterUrl,
        'overview': movie.overview,
        'voteAverage': movie.voteAverage,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      estadoIndex: 1,
      title: 'Buscar',
      screen: Column(
        children: [
          MovieSearchBar(onChanged: _onSearchChanged),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: _savedMoviesStream,
                    builder: (context, savedSnapshot) {
                      final savedMoviesIds = savedSnapshot.hasData
                          ? Set.from(savedSnapshot.data!.docs.map((doc) => doc.id))
                          : <String>{};

                      return ListView.builder(
                        itemCount: _filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _filteredMovies[index];
                          return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('resenias')
                                .where('movieId', isEqualTo: movie.id.toString())
                                .snapshots(),
                            builder: (context, reseniasSnapshot) {
                              final reseniasCount = reseniasSnapshot.data?.docs.length ?? 0;
                              return MovieListItem(
                                movie: movie,
                                isSaved: savedMoviesIds.contains(movie.id.toString()),
                                reseniasCount: reseniasCount,
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
                                onGuardar: () => _guardarEnMiLista(movie),
                                onResenias: null,
                              );
                            },
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