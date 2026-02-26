import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../models/category_model.dart';

/// Handles Firestore CRUD for categories (subcollection of shops).
class CategoryRepository {
  CollectionReference<Map<String, dynamic>> _categoriesRef(String shopId) =>
      FirebaseService.firestore
          .collection(AppConstants.shopsCol)
          .doc(shopId)
          .collection(AppConstants.categoriesCol);

  /// Get all categories for a shop.
  Future<List<CategoryModel>> getCategories(String shopId) async {
    final snap = await _categoriesRef(shopId).orderBy('name').get();
    return snap.docs
        .map((d) => CategoryModel.fromMap(d.data(), d.id, shopId))
        .toList();
  }

  /// Add a new category.
  Future<String> addCategory(String shopId, CategoryModel category) async {
    final doc = await _categoriesRef(shopId).add(category.toMap());
    return doc.id;
  }

  /// Update an existing category.
  Future<void> updateCategory(
    String shopId,
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    await _categoriesRef(shopId).doc(categoryId).update(data);
  }

  /// Delete a category.
  Future<void> deleteCategory(String shopId, String categoryId) async {
    await _categoriesRef(shopId).doc(categoryId).delete();
  }
}
