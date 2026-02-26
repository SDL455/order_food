import 'package:get/get.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../data/models/shop_model.dart';
import '../../../../data/repositories/shop_repository.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/models/order_model.dart';
import '../../../../routes/app_routes.dart';

/// Admin dashboard controller — loads shop info and recent orders.
class AdminDashboardController extends GetxController {
  final ShopRepository _shopRepo = ShopRepository();
  final OrderRepository _orderRepo = OrderRepository();

  final Rxn<ShopModel> shop = Rxn<ShopModel>();
  final orders = <OrderModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      // Find shop owned by current admin
      shop.value = await _shopRepo.getShopByOwner(FirebaseService.uid);

      if (shop.value != null) {
        // Listen to orders for this shop
        _orderRepo.streamShopOrders(shop.value!.id).listen((list) {
          orders.value = list;
        });
      }
    } catch (e, st) {
      AppLogger.e('_load dashboard failed', e, st);
      Get.snackbar('Error', 'Failed to load dashboard');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a shop for a new admin (first-time setup).
  Future<void> createShop(String name) async {
    try {
      final newShop = ShopModel(
        id: '',
        ownerUid: FirebaseService.uid,
        name: name,
      );
      await _shopRepo.saveShop(newShop);
      await _load();
    } catch (e, st) {
      AppLogger.e('createShop failed', e, st);
      Get.snackbar('Error', 'Failed to create shop');
    }
  }

  int get pendingCount => orders.where((o) => o.status == 'pending').length;
  int get activeCount => orders
      .where((o) => ['accepted', 'cooking', 'delivering'].contains(o.status))
      .length;
  int get completedCount => orders.where((o) => o.status == 'done').length;

  Future<void> logout() async {
    await FirebaseService.auth.signOut();
    Get.offAllNamed(AppRoutes.home);
  }
}
