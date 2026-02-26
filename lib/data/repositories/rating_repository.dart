import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../models/rating_model.dart';

/// Handles Firestore CRUD for product ratings.
class RatingRepository {
  CollectionReference<Map<String, dynamic>> _ratingsRef(
    String shopId,
    String productId,
  ) => FirebaseService.firestore
      .collection(AppConstants.shopsCol)
      .doc(shopId)
      .collection(AppConstants.productsCol)
      .doc(productId)
      .collection(AppConstants.ratingsCol);

  DocumentReference<Map<String, dynamic>> _productRef(
    String shopId,
    String productId,
  ) => FirebaseService.firestore
      .collection(AppConstants.shopsCol)
      .doc(shopId)
      .collection(AppConstants.productsCol)
      .doc(productId);

  /// Add or update a rating for a product by the current user.
  Future<void> addRating({
    required String shopId,
    required String productId,
    required RatingModel rating,
  }) async {
    final uid = rating.uid;
    await _ratingsRef(shopId, productId).doc(uid).set(rating.toMap());

    // Recalculate average rating
    final snap = await _ratingsRef(shopId, productId).get();
    final ratings = snap.docs.map((d) => (d.data()['stars'] ?? 0).toDouble());
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.reduce((a, b) => a + b) / ratings.length;

    await _productRef(
      shopId,
      productId,
    ).update({'avgRating': avg, 'ratingCount': snap.docs.length});
  }

  /// Get all ratings for a product.
  Future<List<RatingModel>> getRatings(String shopId, String productId) async {
    final snap = await _ratingsRef(
      shopId,
      productId,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => RatingModel.fromMap(d.data(), d.id)).toList();
  }
}
