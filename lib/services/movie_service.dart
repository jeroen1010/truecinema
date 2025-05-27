import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String _apiKey = '1388700110d57af0a67dfbc5490d582a';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static Future<List<Movie>> fetchAllMovies({int maxPages = 5}) async {
    List<Movie> allMovies = [];
    for (int page = 1; page <= maxPages; page++) {
      final url = Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=es-ES&page=$page');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List results = decoded['results'];
        final moviesPage = results
            .where((movieJson) =>
                movieJson['poster_path'] != null &&
                movieJson['title'] != null &&
                movieJson['overview'] != null &&
                movieJson['vote_average'] != null)
            .map((movieJson) => Movie(
                  id: movieJson['id'],
                  title: movieJson['title'],
                  posterUrl:
                      'https://image.tmdb.org/t/p/w500${movieJson['poster_path']}',
                  overview: movieJson['overview'],
                  voteAverage: (movieJson['vote_average'] as num).toDouble(),
                ))
            .toList();
        allMovies.addAll(moviesPage);
      } else {
        throw Exception('Error al cargar películas (página $page)');
      }
    }
    return allMovies;
  }

  static Future<List<Movie>> searchMovies(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
          '$_baseUrl/search/movie?api_key=$_apiKey&language=es-ES&query=$encodedQuery&page=1');
      
      final response = await http.get(url);
      if (response.statusCode != 200) throw Exception('Error en búsqueda');
      
      final List<dynamic> results = json.decode(response.body)['results'];
      
      // Conversión segura a Movie
      final List<Movie> movies = results
          .where((m) => _isValidMovie(m))
          .map((m) => _parseMovie(m))
          .toList();
      
      return movies;
    } catch (e) {
      throw Exception('Error en búsqueda: ${e.toString()}');
    }
  }

  // Validación mejorada
  static bool _isValidMovie(dynamic movie) {
    return movie is Map<String, dynamic> &&
        movie['id'] != null &&
        movie['poster_path'] != null &&
        movie['title'] != null &&
        movie['overview'] != null &&
        movie['vote_average'] != null;
  }

  // Parseo tipo-safe
  static Movie _parseMovie(Map<String, dynamic> movie) {
    return Movie(
      id: movie['id'] as int,
      title: movie['title'] as String,
      posterUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
      overview: movie['overview'] as String,
      voteAverage: (movie['vote_average'] as num).toDouble(),
    );
  }
}