import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../models/models.dart';

class MoviesCarousel extends StatelessWidget {
  final String title;
  final Future<List<Movie>> moviesFuture;
  final Function(Movie) onMovieTap;

  const MoviesCarousel({
    required this.title,
    required this.moviesFuture,
    required this.onMovieTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        FutureBuilder<List<Movie>>(
          future: moviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 180,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(child: Text('No hay películas')),
              );
            } else {
              final movies = snapshot.data!;
              return CarouselSlider.builder(
                itemCount: movies.length,
                itemBuilder: (context, index, realIndex) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () => onMovieTap(movie),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.fullPosterUrl,
                        fit: BoxFit.cover,
                        width: 120,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 180,
                  viewportFraction: 0.35,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
