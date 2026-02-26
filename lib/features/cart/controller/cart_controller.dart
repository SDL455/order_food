import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';

/// Cart controller — stores items locally via GetStorage.
/// Works for both guest and logged-in users.
class CartController extends GetxController {
  static const _storageKey = 'cart_items';
  final _box = GetStorage();

  final items = <CartItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final raw = _box.read<String>(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      items.value = list
          .map((e) => CartItemModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }
  }

  void _saveToStorage() {
    final list = items.map((e) => e.toMap()).toList();
    _box.write(_storageKey, jsonEncode(list));
  }

  /// Add a product to the cart (or increment qty if already exists).
  void addToCart(ProductModel product) {
    final idx = items.indexWhere((e) => e.productId == product.id);
    if (idx >= 0) {
      items[idx].qty++;
      items.refresh();
    } else {
      items.add(
        CartItemModel(
          productId: product.id,
          shopId: product.shopId,
          name: product.name,
          price: product.price,
          imageUrl: product.displayImageUrl,
        ),
      );
    }
    _saveToStorage();
  }

  /// Remove an item from the cart.
  void removeFromCart(String productId) {
    items.removeWhere((e) => e.productId == productId);
    _saveToStorage();
  }

  /// Update quantity for an item.
  void updateQty(String productId, int qty) {
    if (qty <= 0) {
      removeFromCart(productId);
      return;
    }
    final idx = items.indexWhere((e) => e.productId == productId);
    if (idx >= 0) {
      items[idx].qty = qty;
      items.refresh();
      _saveToStorage();
    }
  }

  /// Clear all items.
  void clearCart() {
    items.clear();
    _saveToStorage();
  }

  /// Cart subtotal.
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.qty);

  /// Number of items in cart.
  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  /// Get the shop ID the cart items belong to (first item's shopId).
  String get cartShopId => items.isNotEmpty ? items.first.shopId : '';
}
