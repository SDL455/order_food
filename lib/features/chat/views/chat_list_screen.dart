import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/shop_model.dart';
import '../controller/chat_controller.dart';
import '../widgets/chat_list_item.dart';
import '../widgets/chat_shop_item.dart';
import '../widgets/chat_shop_search_bar.dart';

/// Chat list screen — shows conversations for customer or admin.
class ChatListScreen extends GetView<ChatController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Chats'),
        centerTitle: true,
      ),
      body: controller.isAdmin ? _buildAdminBody() : _buildCustomerBody(),
    );
  }

  Widget _buildAdminBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }
      if (controller.chats.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'No conversations yet',
          subtitle: 'Customer messages will appear here',
        );
      }
      return _buildChatList();
    });
  }

  Widget _buildCustomerBody() {
    return Obx(() {
      if (controller.isLoading.value && controller.chats.isEmpty) {
        return _buildLoadingState();
      }
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: ChatShopSearchBar(
                onChanged: (v) => controller.searchQuery.value = v,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.store_rounded, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'ຊອກຫາແອັດມິນ/ຮ້ານເພື່ອສົນທະນາ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (controller.isShopsLoading.value)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            )
          else if (controller.filteredShops.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'ບໍ່ພົບຮ້ານ',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final shop = controller.filteredShops[i];
                  return ChatShopItem(
                        shop: shop,
                        onTap: () => _startChatWithShop(shop),
                      )
                      .animate(delay: (i * 40).ms)
                      .fadeIn()
                      .slideX(begin: 0.03, end: 0);
                }, childCount: controller.filteredShops.length),
              ),
            ),
          if (controller.chats.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Icon(Icons.chat_rounded, size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'ການສົນທະນາກັບຮ້ານ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((_, i) {
                  final chat = controller.chats[i];
                  return ChatListItem(
                        chat: chat,
                        isAdmin: false,
                        onTap: () {
                          controller.openChat(chat);
                          Get.toNamed(AppRoutes.chat);
                        },
                      )
                      .animate(delay: (i * 40).ms)
                      .fadeIn()
                      .slideX(begin: 0.03, end: 0);
                }, childCount: controller.chats.length),
              ),
            ),
          ],
        ],
      );
    });
  }

  Future<void> _startChatWithShop(ShopModel shop) async {
    await controller.startChatWithShop(shop.id);
    Get.toNamed(AppRoutes.chat);
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: controller.chats.length,
      itemBuilder: (_, i) {
        final chat = controller.chats[i];
        return ChatListItem(
          chat: chat,
          isAdmin: controller.isAdmin,
          onTap: () {
            controller.openChat(chat);
            Get.toNamed(AppRoutes.chat);
          },
        ).animate(delay: (i * 50).ms).fadeIn().slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          4,
          (index) =>
              Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.cardShadow,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: Colors.grey.shade100),
        ),
      ),
    );
  }
}
