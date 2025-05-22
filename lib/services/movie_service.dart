import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String _apiKey = '1388700110d57af0a67dfbc5490d582a';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

    static Future<List<Movie>> fetchAllMovies({int maxPages = 10}) async {
      List<Movie> allMovies = [];

      for (int page = 1; page <= maxPages; page++) {
        final url = Uri.parse('$_baseUrl/discover/movie?api_key=$_apiKey&language=es-ES&page=$page');
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
                    posterUrl: 'https://image.tmdb.org/t/p/w500${movieJson['poster_path']}',
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

}
