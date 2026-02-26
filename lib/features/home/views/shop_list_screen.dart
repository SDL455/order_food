import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../routes/app_routes.dart';
import '../controller/home_controller.dart';

/// Home screen — displays a list of shops with search.
class ShopListScreen extends GetView<HomeController> {
  const ShopListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍔 Order Food'),
        actions: [
          // Cart button
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Get.toNamed(AppRoutes.cart),
          ),
          // Profile / Login
          IconButton(
            icon: Icon(
              FirebaseService.isLoggedIn ? Icons.person : Icons.person_outline,
            ),
            onPressed: () {
              if (FirebaseService.isLoggedIn) {
                Get.toNamed(AppRoutes.profile);
              } else {
                Get.toNamed(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      // Bottom navigation for logged-in users
      bottomNavigationBar: FirebaseService.isLoggedIn
          ? BottomNavigationBar(
              currentIndex: 0,
              onTap: (i) {
                switch (i) {
                  case 0:
                    break; // Already on home
                  case 1:
                    Get.toNamed(AppRoutes.orders);
                    break;
                  case 2:
                    Get.toNamed(AppRoutes.chatList);
                    break;
                  case 3:
                    Get.toNamed(AppRoutes.profile);
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.searchQuery.value = '',
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Shop list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final shops = controller.filteredShops;
              if (shops.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No restaurants found',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchShops,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: shops.length,
                  itemBuilder: (_, i) {
                    final shop = shops[i];
                    return GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.shopDetail, arguments: shop.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: shop.coverUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: shop.coverUrl,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        height: 160,
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 160,
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.restaurant,
                                          size: 48,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                            ),
                            // Info
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          shop.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: shop.isOpen
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              shop.isOpen ? 'Open' : 'Closed',
                                              style: TextStyle(
                                                color: shop.isOpen
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
