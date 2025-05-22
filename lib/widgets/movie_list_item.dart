import 'package:flutter/material.dart';
import '../models/models.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onGuardar;
  final VoidCallback? onResenias;
  final VoidCallback? onEliminar;

  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onGuardar,
    this.onResenias,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la película
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie.posterUrl,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 150,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Información a la derecha
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (onResenias != null)
                                ElevatedButton(
                                  onPressed: onResenias,
                                  child: const Text("Reseñas"),
                                ),
                              if (onResenias != null)
                                const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: onGuardar,
                                icon: const Icon(Icons.bookmark_add),
                                label: const Text("Guardar"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Estrella y puntuación en la esquina superior derecha
                    Positioned(
                      top: 0,
                      right: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
