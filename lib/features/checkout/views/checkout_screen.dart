import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/loading_button.dart';
import '../../cart/controller/cart_controller.dart';
import '../controller/checkout_controller.dart';
import '../widgets/order_summary_card.dart';

/// Checkout screen — address input, order summary, and place order.
class CheckoutScreen extends GetView<CheckoutController> {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => controller.addressText.value = v,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your delivery address...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on_outlined),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Note (optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => controller.note.value = v,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Special instructions...',
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Obx(
                () => Column(
                  children: [
                    ...cartCtrl.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} x${item.qty}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '\$${(item.price * item.qty).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    SummaryRow(
                      label: 'Subtotal',
                      value: '\$${cartCtrl.subtotal.toStringAsFixed(2)}',
                    ),
                    SummaryRow(
                      label: 'Delivery Fee',
                      value: '\$${controller.deliveryFee.value.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    SummaryRow(
                      label: 'Total',
                      value: '\$${controller.total.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Obx(
              () => LoadingButton(
                label: 'Place Order',
                isLoading: controller.isLoading.value,
                onPressed: controller.placeOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
