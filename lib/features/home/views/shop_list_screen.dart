import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart';
import '../controller/home_controller.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/shop_card.dart';
import '../widgets/shop_search_bar.dart';

class ShopListScreen extends GetView<HomeController> {
  const ShopListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white,
                      AppTheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Order Food',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => Get.toNamed(AppRoutes.cart),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    FirebaseService.isLoggedIn
                        ? Icons.person
                        : Icons.person_outline,
                  ),
                  onPressed: () {
                    if (FirebaseService.isLoggedIn) {
                      Get.toNamed(AppRoutes.profile);
                    } else {
                      Get.toNamed(AppRoutes.login);
                    }
                  },
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShopSearchBar(
                        controller: controller.searchController,
                        onChanged: (v) => controller.searchQuery.value = v,
                        onClear: () => controller.searchQuery.value = '',
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 20),
                  Text(
                    'Popular Restaurants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              final shops = controller.filteredShops;
              if (shops.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.store_outlined,
                  title: 'No restaurants found',
                  subtitle: 'Try searching for something else',
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: List.generate(shops.length, (index) {
                    final shop = shops[index];
                    return ShopCard(
                          shop: shop,
                          onTap: () => Get.toNamed(
                            AppRoutes.shopDetail,
                            arguments: shop.id,
                          ),
                        )
                        .animate(delay: (index * 100).ms)
                        .fadeIn()
                        .slideX(begin: 0.1, end: 0);
                  }),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: FirebaseService.isLoggedIn
          ? const MainBottomNav()
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          3,
          (index) =>
              Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1200.ms, color: Colors.grey.shade100),
        ),
      ),
    );
  }
}
