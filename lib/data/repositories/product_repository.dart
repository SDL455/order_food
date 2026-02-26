import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../models/product_model.dart';

/// Handles Firestore CRUD for products (subcollection of shops).
class ProductRepository {
  CollectionReference<Map<String, dynamic>> _productsRef(String shopId) =>
      FirebaseService.firestore
          .collection(AppConstants.shopsCol)
          .doc(shopId)
          .collection(AppConstants.productsCol);

  /// Get all active products for a shop.
  Future<List<ProductModel>> getProducts(String shopId) async {
    final snap = await _productsRef(shopId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => ProductModel.fromMap(d.data(), d.id, shopId))
        .toList();
  }

  /// Get ALL products for a shop (including inactive — admin view).
  Future<List<ProductModel>> getAllProducts(String shopId) async {
    final snap = await _productsRef(
      shopId,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs
        .map((d) => ProductModel.fromMap(d.data(), d.id, shopId))
        .toList();
  }

  /// Get a single product.
  Future<ProductModel?> getProduct(String shopId, String productId) async {
    final doc = await _productsRef(shopId).doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.data()!, doc.id, shopId);
  }

  /// Add a new product.
  Future<String> addProduct(String shopId, ProductModel product) async {
    final doc = await _productsRef(shopId).add(product.toMap());
    return doc.id;
  }

  /// Update an existing product.
  Future<void> updateProduct(
    String shopId,
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _productsRef(shopId).doc(productId).update(data);
  }

  /// Soft-delete a product (set isActive = false).
  Future<void> deleteProduct(String shopId, String productId) async {
    await _productsRef(shopId).doc(productId).update({'isActive': false});
  }
}
