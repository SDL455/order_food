import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controller/shop_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_grid_card.dart';

class ShopDetailScreen extends GetView<ShopController> {
  const ShopDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        final shop = controller.shop.value;
        if (shop == null) {
          return const Center(child: Text('Shop not found'));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: Colors.white,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Get.toNamed(AppRoutes.cart),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    shop.coverUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: shop.coverUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 64,
                                color: AppTheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: shop.isOpen ? AppTheme.success : AppTheme.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  shop.isOpen ? 'Open' : 'Closed',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '4.5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '15-25 min',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (controller.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      CategoryChip(
                        label: 'All',
                        isSelected: controller.selectedCategory.value.isEmpty,
                        onTap: () => controller.selectedCategory.value = '',
                      ),
                      ...controller.categories.map(
                        (c) => CategoryChip(
                          label: c,
                          isSelected: controller.selectedCategory.value == c,
                          onTap: () => controller.selectedCategory.value = c,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate((_, i) {
                  final product = controller.filteredProducts[i];
                  return ProductGridCard(
                    product: product,
                    onTap: () => Get.toNamed(
                      AppRoutes.productDetail,
                      arguments: {
                        'shopId': product.shopId,
                        'productId': product.id,
                      },
                    ),
                  ).animate(delay: (i * 50).ms).fadeIn().scale(begin: const Offset(0.95, 0.95));
                }, childCount: controller.filteredProducts.length),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: Colors.grey.shade200,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.grey.shade100),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
