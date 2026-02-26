import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_service.dart';
import '../../../features/cart/controller/cart_controller.dart';
import '../controller/product_detail_controller.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/rating_input_widget.dart';
import '../widgets/review_card.dart';
import '../widgets/star_rating_display.dart';

class ProductDetailScreen extends GetView<ProductDetailController> {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }
        final product = controller.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found'));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
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
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.displayImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.displayImageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.fastfood,
                                size: 64,
                                color: AppTheme.textSecondary,
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
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                                const SizedBox(height: 8),
                                if (product.ratingCount > 0)
                                  Row(
                                    children: [
                                      StarRatingDisplay(rating: product.avgRating),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${product.avgRating.toStringAsFixed(1)} (${product.ratingCount} reviews)',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 100.ms),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms).scale(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (product.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 20),

                      if (product.desc.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ).animate().fadeIn(delay: 250.ms),
                        const SizedBox(height: 10),
                        Text(
                          product.desc,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],

                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                      const SizedBox(height: 12),

                      if (FirebaseService.isLoggedIn) ...[
                        RatingInputWidget(
                          userStars: controller.userStars,
                          userComment: controller.userComment,
                          onSubmit: controller.submitRating,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 20),
                      ],

                      ...controller.ratings.asMap().entries.map(
                            (entry) => ReviewCard(rating: entry.value)
                                .animate(delay: (450 + entry.key * 50).ms)
                                .fadeIn()
                                .slideX(begin: 0.1, end: 0),
                          ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      bottomSheet: Obx(() {
        final product = controller.product.value;
        if (product == null) return const SizedBox.shrink();
        return ProductBottomBar(
          productName: product.name,
          price: product.price,
          onAddToCart: () {
            final cartCtrl = Get.find<CartController>();
            cartCtrl.addToCart(controller.product.value!);
            Get.snackbar(
              'Added to Cart',
              '${product.name} added to your cart!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.success,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              icon: const Icon(Icons.check_circle, color: Colors.white),
            );
          },
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: Colors.grey.shade200,
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 400,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
        ),
      ],
    );
  }
}
