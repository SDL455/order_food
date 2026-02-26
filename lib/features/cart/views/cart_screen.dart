import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart';
import '../controller/cart_controller.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_bar.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.white,
        actions: [
          Obx(
            () => controller.items.isNotEmpty
                ? TextButton.icon(
                    onPressed: () => _confirmClear(context),
                    icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                    label: const Text(
                      'Clear',
                      style: TextStyle(color: AppTheme.error),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            subtitle: 'Add some delicious food to get started',
            buttonLabel: 'Browse Restaurants',
            buttonIcon: Icons.explore,
            onButtonPressed: () => Get.offAllNamed(AppRoutes.home),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.items.length,
                itemBuilder: (_, i) {
                  final item = controller.items[i];
                  return CartItemCard(
                    item: item,
                    onQtyChanged: (qty) => controller.updateQty(item.productId, qty),
                  ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.1, end: 0);
                },
              ),
            ),
            CartSummaryBar(
              subtotal: controller.subtotal,
              itemCount: controller.items.length,
              onCheckoutPressed: () {
                if (!FirebaseService.isLoggedIn) {
                  Get.defaultDialog(
                    title: 'Login Required',
                    middleText: 'Please login to checkout',
                    textConfirm: 'Login',
                    textCancel: 'Cancel',
                    confirmTextColor: Colors.white,
                    buttonColor: AppTheme.primary,
                    onConfirm: () {
                      Get.back();
                      Get.toNamed(AppRoutes.login);
                    },
                  );
                  return;
                }
                Get.toNamed(AppRoutes.checkout);
              },
            ),
          ],
        );
      }),
    );
  }

  void _confirmClear(BuildContext context) {
    Get.defaultDialog(
      title: 'Clear Cart',
      middleText: 'Remove all items from cart?',
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.error,
      onConfirm: () {
        controller.clearCart();
        Get.back();
      },
    );
  }
}
