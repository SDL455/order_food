import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore rating document model (subcollection of a product).
class RatingModel {
  final String uid;
  final double stars;
  final String comment;
  final DateTime createdAt;

  RatingModel({
    required this.uid,
    required this.stars,
    this.comment = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RatingModel.fromMap(Map<String, dynamic> map, String uid) {
    return RatingModel(
      uid: uid,
      stars: (map['stars'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'stars': stars,
    'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
