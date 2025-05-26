import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truecinema/models/models.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final List<Actor> actors;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.actors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(movie.posterUrl),
            const SizedBox(height: 20),
            Text(
              'Sinopsis:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(movie.overview),
            const SizedBox(height: 20),
            Text(
              'Reparto:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: actors.length,
                itemBuilder: (context, index) {
                  final actor = actors[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(actor.profileUrl),
                        ),
                        Text(actor.name),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reseñas:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('resenias')
                  .where('movieId', isEqualTo: movie.id.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                
                final resenias = snapshot.data!.docs
                    .map((doc) => Resenia.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: resenias.length,
                  itemBuilder: (context, index) {
                    final resenia = resenias[index];
                    return Card(
                      child: ListTile(
                        title: Text(resenia.userName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${resenia.rating}/10'),
                            Text(resenia.comment),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}