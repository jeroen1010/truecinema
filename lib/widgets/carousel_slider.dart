import 'package:flutter/material.dart';

import '../models/models.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final Function(Movie) onMovieTap;
  final bool showRating;

  const MovieCarousel({
    super.key,
    required this.title,
    required this.movies,
    required this.onMovieTap,
    this.showRating = false,
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
        SizedBox(
          height: showRating ? 220 : 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => onMovieTap(movie),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie.posterUrl,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey, height: 180),
                        ),
                      ),
                      if (showRating) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
