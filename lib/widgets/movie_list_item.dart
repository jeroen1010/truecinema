import 'package:flutter/material.dart';
import '../models/models.dart';

class MovieListItem extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onGuardar;
  final VoidCallback? onResenias;
  final VoidCallback? onEliminar;
  final bool isSaved;

  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
    required this.onGuardar,
    this.onResenias,
    this.onEliminar,
    required this.isSaved,
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
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila título + puntuación
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Puntuación
                        Row(
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
                      ],
                    ),
                    // Sinopsis
                    const SizedBox(height: 4),
                    Text(
                      movie.overview,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Botones
                    Row(
                      children: [
                        if (onResenias != null)
                          ElevatedButton(
                            onPressed: onResenias,
                            child: const Text("Reseñas"),
                          ),
                        if (onResenias != null)
                          const SizedBox(width: 8),
                        // Botón condicional
                        if (onEliminar != null)
                          ElevatedButton.icon(
                            onPressed: onEliminar,
                            icon: const Icon(Icons.delete),
                            label: const Text("Eliminar"),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: isSaved ? null : onGuardar,
                            icon: Icon(
                              isSaved ? Icons.check : Icons.bookmark_add,
                              color: isSaved ? Colors.green : null,
                            ),
                            label: Text(isSaved ? "Guardada" : "Guardar"),
                          ),
                      ],
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