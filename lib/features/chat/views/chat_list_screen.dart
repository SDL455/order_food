import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/chat_model.dart';
import '../../../data/models/shop_model.dart';
import '../controller/chat_controller.dart';

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
        title: Text('Chats'),
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
          // Search bar — ຊອກຫາແອັດມິນ/ຮ້ານ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _ShopSearchBar(
                onChanged: (v) => controller.searchQuery.value = v,
              ),
            ),
          ),
          // Section: ເລີ່ມສົນທະນາກັບຮ້ານ
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
                  return _ShopChatItem(
                        shop: shop,
                        onTap: () => _startChatWithShop(shop),
                      )
                      .animate(delay: (i * 40).ms)
                      .fadeIn()
                      .slideX(begin: 0.03, end: 0);
                }, childCount: controller.filteredShops.length),
              ),
            ),
          // Section: ການສົນທະນາກັບຮ້ານ
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
                  return _ChatItem(
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
        return _ChatItem(
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

class _ShopSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _ShopSearchBar({required this.onChanged});

  @override
  State<_ShopSearchBar> createState() => _ShopSearchBarState();
}

class _ShopSearchBarState extends State<_ShopSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'ຊອກຫາແອັດມິນ ຫຼື ຮ້ານເພື່ອສົນທະນາ...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _ShopChatItem extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const _ShopChatItem({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: shop.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop.coverUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ແອັດມິນຮ້ານ',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final ChatModel chat;
  final bool isAdmin;
  final VoidCallback onTap;

  const _ChatItem({
    required this.chat,
    required this.isAdmin,
    required this.onTap,
  });

  String get _displayName {
    if (isAdmin) {
      return 'Customer: ${chat.customerUid.substring(0, 8)}...';
    }
    return 'Shop: ${chat.shopId.substring(0, 8)}...';
  }

  String get _displayMessage =>
      chat.lastMessage.isNotEmpty ? chat.lastMessage : 'No messages yet';

  String get _timeStr {
    final hour = chat.lastAt.hour;
    final minute = chat.lastAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _displayMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _timeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
