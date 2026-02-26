import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/shop_repository.dart';

/// Controller for the shop detail screen — loads shop info + products.
class ShopController extends GetxController {
  final ShopRepository _shopRepo = ShopRepository();
  final ProductRepository _productRepo = ProductRepository();

  final Rxn<ShopModel> shop = Rxn<ShopModel>();
  final products = <ProductModel>[].obs;
  final isLoading = true.obs;
  final selectedCategory = ''.obs;

  String get shopId => Get.arguments as String? ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      shop.value = await _shopRepo.getShop(shopId);
      products.value = await _productRepo.getProducts(shopId);
    } catch (e, st) {
      AppLogger.e('_load shop failed', e, st);
      Get.snackbar('Error', 'Failed to load shop');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get unique categories.
  List<String> get categories {
    final cats = products
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  /// Filtered products by category.
  List<ProductModel> get filteredProducts {
    if (selectedCategory.value.isEmpty) return products;
    return products.where((p) => p.category == selectedCategory.value).toList();
  }
}
