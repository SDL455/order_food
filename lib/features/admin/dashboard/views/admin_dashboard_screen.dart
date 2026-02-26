import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/app_routes.dart';
import '../../widgets/admin_menu_item.dart';
import '../../widgets/stat_card.dart';
import '../controller/admin_dashboard_controller.dart';

/// Admin dashboard — shop setup, stats, and navigation to admin features.
class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.shop.value == null) {
          return _buildCreateShop();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.shop.value!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  StatCard(
                    icon: Icons.pending_actions,
                    label: 'Pending',
                    count: controller.pendingCount,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Active',
                    count: controller.activeCount,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Done',
                    count: controller.completedCount,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AdminMenuItem(
                icon: Icons.fastfood_outlined,
                title: 'Manage Products',
                subtitle: 'Add, edit, or remove menu items',
                onTap: () => Get.toNamed(
                  AppRoutes.adminProducts,
                  arguments: controller.shop.value!.id,
                ),
              ),
              AdminMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Manage Orders',
                subtitle: 'View and update order statuses',
                onTap: () => Get.toNamed(
                  AppRoutes.adminOrders,
                  arguments: controller.shop.value!.id,
                ),
              ),
              AdminMenuItem(
                icon: Icons.chat_outlined,
                title: 'Customer Chats',
                subtitle: 'Chat with customers',
                onTap: () => Get.toNamed(
                  AppRoutes.adminChatList,
                  arguments: controller.shop.value!.id,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCreateShop() {
    final nameCtrl = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store_outlined, size: 64, color: AppTheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Set up your shop',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'Shop name'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  controller.createShop(nameCtrl.text.trim());
                }
              },
              child: const Text('Create Shop'),
            ),
          ),
        ],
      ),
    );
  }
}
