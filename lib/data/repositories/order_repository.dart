import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../models/order_model.dart';

/// Handles Firestore CRUD for orders.
class OrderRepository {
  final _orders = FirebaseService.firestore.collection(AppConstants.ordersCol);

  /// Create a new order. Returns the order ID.
  Future<String> createOrder(OrderModel order) async {
    final doc = await _orders.add(order.toMap());
    return doc.id;
  }

  /// Stream customer's orders (real-time).
  Stream<List<OrderModel>> streamCustomerOrders(String customerUid) {
    return _orders
        .where('customerUid', isEqualTo: customerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// Stream shop's orders (real-time, for admin).
  Stream<List<OrderModel>> streamShopOrders(String shopId) {
    return _orders
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  /// Update order status.
  Future<void> updateStatus(String orderId, String status) async {
    await _orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a single order.
  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.data()!, doc.id);
  }
}
