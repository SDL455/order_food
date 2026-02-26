import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart';
import '../controller/orders_controller.dart';
import '../widgets/order_card.dart';

class OrdersScreen extends GetView<CustomerOrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.offAllNamed(AppRoutes.home),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        if (controller.orders.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            subtitle: 'Your order history will appear here',
            buttonLabel: 'Start Ordering',
            buttonIcon: Icons.explore,
            onButtonPressed: () => Get.offAllNamed(AppRoutes.home),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.orders.length,
          itemBuilder: (_, i) {
            final order = controller.orders[i];
            return OrderCard(
              order: order,
              animationDelay: i * 100,
            ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.1, end: 0);
          },
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4,
          itemBuilder: (context, index) => Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.shade100),
    );
  }
}
