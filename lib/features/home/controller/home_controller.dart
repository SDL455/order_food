import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/models/shop_model.dart';
import '../../../data/repositories/shop_repository.dart';

/// Controller for the shop list (home) screen.
class HomeController extends GetxController {
  final ShopRepository _repo = ShopRepository();

  final shops = <ShopModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

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

  /// Filtered shops based on search query.
  List<ShopModel> get filteredShops {
    if (searchQuery.value.isEmpty) return shops;
    return shops
        .where(
          (s) => s.name.toLowerCase().contains(searchQuery.value.toLowerCase()),
        )
        .toList();
  }
}
