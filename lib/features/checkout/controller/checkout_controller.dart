import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../routes/app_routes.dart';
import '../../cart/controller/cart_controller.dart';

/// Controller for the checkout screen — creates an order from the cart.
class CheckoutController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (!FirebaseService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        Get.defaultDialog(
          title: 'Login Required',
          middleText: 'Please login first',
          textConfirm: 'Login',
          textCancel: 'Cancel',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            Get.toNamed(AppRoutes.login);
          },
        );
      });
    }
  }
  final addressText = ''.obs;
  final note = ''.obs;
  final deliveryFee = 2.0.obs; // Fixed delivery fee for MVP

  CartController get cartCtrl => Get.find<CartController>();

  double get total => cartCtrl.subtotal + deliveryFee.value;

  /// Place order.
  Future<void> placeOrder() async {
    if (addressText.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your delivery address');
      return;
    }
    try {
      isLoading.value = true;

      final order = OrderModel(
        id: '',
        shopId: cartCtrl.cartShopId,
        customerUid: FirebaseService.uid,
        items: cartCtrl.items
            .map(
              (e) => OrderItem(
                productId: e.productId,
                name: e.name,
                price: e.price,
                qty: e.qty,
                imageUrl: e.imageUrl,
              ),
            )
            .toList(),
        subtotal: cartCtrl.subtotal,
        deliveryFee: deliveryFee.value,
        total: total,
        address: OrderAddress(text: addressText.value.trim()),
        note: note.value,
      );

      await _orderRepo.createOrder(order);

      // Clear cart after successful order
      cartCtrl.clearCart();

      Get.snackbar(
        'Order Placed!',
        'Your order has been sent to the restaurant',
      );
      Get.offAllNamed(AppRoutes.orders);
    } catch (e, st) {
      AppLogger.e('placeOrder failed', e, st);
      Get.snackbar('Error', 'Failed to place order');
    } finally {
      isLoading.value = false;
    }
  }
}
