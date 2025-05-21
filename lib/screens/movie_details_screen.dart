import 'package:flutter/material.dart';

import '../models/models.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final List<Actor> actors;

  const MovieDetailsScreen({super.key, required this.movie, required this.actors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(movie.posterUrl, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(movie.overview),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: actors.length,
                itemBuilder: (context, index) {
                  final actor = actors[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            actor.profileUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey, height: 80, width: 80),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(actor.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

