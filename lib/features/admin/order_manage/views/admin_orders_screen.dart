import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/status_chip.dart';
import '../controller/admin_order_controller.dart';

/// Admin orders screen — view and update order statuses.
class AdminOrdersScreen extends GetView<AdminOrderController> {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.orders.isEmpty) {
          return const Center(
            child: Text(
              'No orders yet',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (_, i) {
            final order = controller.orders[i];
            final nextStatus = controller.getNextStatus(order.status);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      StatusChip(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Text(
                      '• ${item.name} x${item.qty}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.address.text,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (order.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${order.note}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    children: [
                      Text(
                        'Total: \$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Spacer(),
                      if (order.status != AppConstants.statusDone &&
                          order.status != AppConstants.statusCanceled)
                        TextButton(
                          onPressed: () => controller.updateStatus(
                            order.id,
                            AppConstants.statusCanceled,
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppTheme.error),
                          ),
                        ),
                      if (nextStatus != null)
                        ElevatedButton(
                          onPressed: () =>
                              controller.updateStatus(order.id, nextStatus),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(_statusLabel(nextStatus)),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case AppConstants.statusAccepted:
        return 'Accept';
      case AppConstants.statusCooking:
        return 'Start Cooking';
      case AppConstants.statusDelivering:
        return 'Out for Delivery';
      case AppConstants.statusDone:
        return 'Mark Done';
      default:
        return status;
    }
  }
}
