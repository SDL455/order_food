import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';

/// Admin order management controller — streams shop orders, updates status.
class AdminOrderController extends GetxController {
  final OrderRepository _repo = OrderRepository();

  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;

  String get shopId => Get.arguments as String? ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenOrders();
  }

  void _listenOrders() {
    isLoading.value = true;
    _repo.streamShopOrders(shopId).listen((list) {
      orders.value = list;
      isLoading.value = false;
    });
  }

  /// Update order status to next stage.
  Future<void> updateStatus(String orderId, String newStatus) async {
    try {
      await _repo.updateStatus(orderId, newStatus);
      Get.snackbar('Updated', 'Order status changed to $newStatus');
    } catch (e, st) {
      AppLogger.e('updateStatus failed', e, st);
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  /// Get the next logical status.
  String? getNextStatus(String currentStatus) {
    const flow = [
      AppConstants.statusPending,
      AppConstants.statusAccepted,
      AppConstants.statusCooking,
      AppConstants.statusDelivering,
      AppConstants.statusDone,
    ];
    final idx = flow.indexOf(currentStatus);
    if (idx >= 0 && idx < flow.length - 1) return flow[idx + 1];
    return null;
  }
}
