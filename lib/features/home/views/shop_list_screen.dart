import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart';
import '../../shop/widgets/category_chip.dart';
import '../../shop/widgets/product_grid_card.dart';
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
                  Obx(
                    () => Text(
                      controller.shouldShowProducts
                          ? 'Products'
                          : 'Popular Restaurants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            final cats = controller.filteredCategories;
            if (controller.categories.isNotEmpty)
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: [
                      CategoryChip(
                        label: 'All',
                        isSelected: controller.selectedCategory.value.isEmpty,
                        onTap: () => controller.selectedCategory.value = '',
                      ),
                      ...cats.map(
                        (c) => CategoryChip(
                          label: c,
                          isSelected: controller.selectedCategory.value == c,
                          onTap: () => controller.selectedCategory.value = c,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }),

          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              final shouldShowProducts = controller.shouldShowProducts;
              if (shouldShowProducts) {
                final products = controller.filteredProducts;
                if (products.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: 'No products in this category',
                    subtitle: 'Try another category or search',
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final product = products[i];
                      return ProductGridCard(
                            product: product,
                            onTap: () => Get.toNamed(
                              AppRoutes.productDetail,
                              arguments: {
                                'shopId': product.shopId,
                                'productId': product.id,
                              },
                            ),
                          )
                          .animate(delay: (i * 50).ms)
                          .fadeIn()
                          .scale(begin: const Offset(0.95, 0.95));
                    },
                  ),
                );
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
