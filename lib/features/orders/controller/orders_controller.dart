import 'package:get/get.dart';

import '../../../core/services/firebase_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

/// Controller for the customer orders screen — streams user's orders.
class CustomerOrdersController extends GetxController {
  final OrderRepository _repo = OrderRepository();

  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenOrders();
  }

  void _listenOrders() {
    isLoading.value = true;
    _repo.streamCustomerOrders(FirebaseService.uid).listen((list) {
      orders.value = list;
      isLoading.value = false;
    });
  }
}
