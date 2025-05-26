
import 'package:cloud_firestore/cloud_firestore.dart';

class Resenia {
  final String id;
  final String movieId;
  final String userId;
  final String userName;
  final String movieTitle;
  final int rating;
  final String comment;
  final DateTime timestamp;

  Resenia({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userName,
    required this.movieTitle,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Resenia.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Resenia(
      id: doc.id,
      movieId: data['movieId'],
      userId: data['userId'],
      userName: data['userName'],
      movieTitle: data['movieTitle'],
      rating: data['rating'],
      comment: data['comment'],
      timestamp: data['timestamp'].toDate(),
    );
  }
}