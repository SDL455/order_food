import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/shop_repository.dart';

/// Controller for the shop list (home) screen.
class HomeController extends GetxController {
  final ShopRepository _repo = ShopRepository();
  final ProductRepository _productRepo = ProductRepository();

  final shops = <ShopModel>[].obs;
  final products = <ProductModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchShops();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchShops() async {
    try {
      isLoading.value = true;
      shops.value = await _repo.getShops();
      await _fetchProductsFromAllShops();
    } catch (e, st) {
      AppLogger.e('fetchShops failed', e, st);
      Get.snackbar(
        'Error',
        'Failed to load shops. Check console for details.',
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchProductsFromAllShops() async {
    if (shops.isEmpty) return;
    try {
      final allProducts = <ProductModel>[];
      for (final shop in shops) {
        final shopProducts = await _productRepo.getProducts(shop.id);
        allProducts.addAll(shopProducts);
      }
      products.value = allProducts;
    } catch (e, st) {
      AppLogger.e('_fetchProductsFromAllShops failed', e, st);
    }
  }

  /// Unique categories from all products across shops.
  List<String> get categories {
    final cats = products
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    return cats;
  }

  /// Categories filtered by search query (for chip display).
  List<String> get filteredCategories {
    if (searchQuery.value.isEmpty) return categories;
    final q = searchQuery.value.toLowerCase();
    return categories.where((c) => c.toLowerCase().contains(q)).toList();
  }

  /// Categories that match the search query (for auto-showing products).
  List<String> get searchMatchedCategories {
    if (searchQuery.value.isEmpty) return [];
    return filteredCategories;
  }

  /// Filtered shops: by name OR has products in category matching search.
  List<ShopModel> get filteredShops {
    if (searchQuery.value.isEmpty) return shops;
    final q = searchQuery.value.toLowerCase();
    return shops.where((s) {
      final nameMatch = s.name.toLowerCase().contains(q);
      if (nameMatch) return true;
      final hasMatchingCategory = products.any(
        (p) =>
            p.shopId == s.id &&
            p.category.isNotEmpty &&
            p.category.toLowerCase().contains(q),
      );
      return hasMatchingCategory;
    }).toList();
  }

  /// Filtered products by category and search query.
  /// When search matches a category, show all products from that category.
  List<ProductModel> get filteredProducts {
    List<ProductModel> result = products.toList();
    final matchedCats = searchMatchedCategories;

    if (selectedCategory.value.isNotEmpty) {
      result =
          result.where((p) => p.category == selectedCategory.value).toList();
    } else if (matchedCats.isNotEmpty) {
      result =
          result.where((p) => matchedCats.contains(p.category)).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      final isSearchCategoryMode =
          matchedCats.isNotEmpty && selectedCategory.value.isEmpty;
      if (!isSearchCategoryMode) {
        result =
            result.where((p) => p.name.toLowerCase().contains(q)).toList();
      }
    }
    return result;
  }

  /// True when we should show products (category selected OR search matches category).
  bool get shouldShowProducts {
    if (selectedCategory.value.isNotEmpty) return true;
    return searchMatchedCategories.isNotEmpty;
  }
}
