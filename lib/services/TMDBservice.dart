import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truecinema/models/models.dart';

class TMDBService {
  static const String apiKey = '1388700110d57af0a67dfbc5490d582a';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchPopularMovies() async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=es-ES&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> fetchNowPlayingMovies() async {
    final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&language=es-ES&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }
}
