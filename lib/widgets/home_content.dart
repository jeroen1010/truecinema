import 'package:flutter/material.dart';
import 'package:truecinema/screens/screens.dart';
import 'package:truecinema/services/TMDBservice.dart';
import 'package:truecinema/widgets/widgets.dart';

import '../models/models.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TMDbApi api = TMDbApi();

  late Future<List<Movie>> popularesFuture;
  late Future<List<Movie>> estrenosFuture;
  late Future<List<Movie>> topRatedFuture;  

  @override
  void initState() {
    super.initState();
    popularesFuture = api.fetchPopularMovies();
    estrenosFuture = api.fetchNowPlayingMovies();
    topRatedFuture = api.fetchTopRatedMovies();  
  }

  void onMovieTap(Movie movie) async {
    final actors = await api.fetchMovieActors(movie.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movie: movie, actors: actors),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<List<Movie>>(
            future: popularesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return MovieCarousel(
                  title: 'Populares',
                  movies: snapshot.data!,
                  onMovieTap: onMovieTap,
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          FutureBuilder<List<Movie>>(
            future: estrenosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return MovieCarousel(
                  title: 'Estrenos',
                  movies: snapshot.data!,
                  onMovieTap: onMovieTap,
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          FutureBuilder<List<Movie>>(
            future: topRatedFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return MovieCarousel(
                  title: 'Mejor Valoradas',
                  movies: snapshot.data!,
                  onMovieTap: onMovieTap,
                  showRating: true,
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
