import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class TMDbApi {
  final String apiKey = '1388700110d57af0a67dfbc5490d582a'; 
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchPopularMovies() async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=es-ES&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie(
        id: movie['id'],
        title: movie['title'],
        posterUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
        overview: movie['overview'],
        voteAverage: (movie['vote_average'] as num).toDouble(), 
      )).toList();
    } else {
      throw Exception('Error cargando populares');
    }
  }

  Future<List<Movie>> fetchNowPlayingMovies() async {
    final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&language=es-ES&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      return results.map((movie) => Movie(
        id: movie['id'],
        title: movie['title'],
        posterUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
        overview: movie['overview'],
        voteAverage: (movie['vote_average'] as num).toDouble(),
      )).toList();
    } else {
      throw Exception('Error cargando estrenos');
    }
  }

  Future<List<Actor>> fetchMovieActors(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey&language=es-ES');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cast = data['cast'] as List;
      return cast.take(10).map((actor) => Actor(
        id: actor['id'],
        name: actor['name'],
        profileUrl: actor['profile_path'] != null
            ? 'https://image.tmdb.org/t/p/w200${actor['profile_path']}'
            : '',
      )).toList();
    } else {
      throw Exception('Error cargando actores');
    }
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
  final url = Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey&language=es-ES&page=1');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final results = data['results'] as List;
    return results.map((movie) => Movie(
      id: movie['id'],
      title: movie['title'],
      posterUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
      overview: movie['overview'],
      voteAverage: (movie['vote_average'] as num).toDouble(),
    )).toList();
  } else {
    throw Exception('Error cargando mejor valoradas');
  }
}

}
