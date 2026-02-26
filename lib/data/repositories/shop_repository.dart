import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/firebase_service.dart';
import '../models/shop_model.dart';

/// Handles Firestore CRUD for the shops collection.
class ShopRepository {
  final _shops = FirebaseService.firestore.collection(AppConstants.shopsCol);

  /// Get all shops.
  /// Uses orderBy when possible; falls back to simple get + sort if index is missing.
  Future<List<ShopModel>> getShops() async {
    try {
      final snap =
          await _shops.orderBy('createdAt', descending: true).get();
      return snap.docs.map((d) => ShopModel.fromMap(d.data(), d.id)).toList();
    } catch (e, st) {
      AppLogger.w('getShops orderBy failed, using fallback', e, st);
      // Fallback: index may be missing or query failed — get all and sort in memory
      final snap = await _shops.get();
      final list =
          snap.docs.map((d) => ShopModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  /// Get a single shop by ID.
  Future<ShopModel?> getShop(String shopId) async {
    final doc = await _shops.doc(shopId).get();
    if (!doc.exists) return null;
    return ShopModel.fromMap(doc.data()!, doc.id);
  }

  /// Create or update a shop.
  Future<void> saveShop(ShopModel shop) async {
    if (shop.id.isEmpty) {
      await _shops.add(shop.toMap());
    } else {
      await _shops.doc(shop.id).set(shop.toMap(), SetOptions(merge: true));
    }
  }

  /// Get shop owned by a specific admin UID.
  Future<ShopModel?> getShopByOwner(String ownerUid) async {
    final snap = await _shops
        .where('ownerUid', isEqualTo: ownerUid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return ShopModel.fromMap(doc.data(), doc.id);
  }
}
