import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../routes/app_routes.dart';
import '../controller/admin_product_controller.dart';

/// Admin product list screen — shows all products with add/edit/delete.
class AdminProductListScreen extends GetView<AdminProductController> {
  const AdminProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Products')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          Get.toNamed(AppRoutes.adminProductForm, arguments: controller.shopId);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.products.isEmpty) {
          return const Center(
            child: Text(
              'No products yet. Add your first product!',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.products.length,
          itemBuilder: (_, i) {
            final p = controller.products[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: p.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: p.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.fastfood),
                        ),
                ),
                title: Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '\$${p.price.toStringAsFixed(2)} • ${p.isActive ? "Active" : "Inactive"}',
                  style: TextStyle(
                    color: p.isActive ? AppTheme.primary : Colors.red,
                  ),
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (val) {
                    if (val == 'edit') {
                      controller.loadProductForEdit(p);
                      Get.toNamed(
                        AppRoutes.adminProductForm,
                        arguments: controller.shopId,
                      );
                    } else if (val == 'delete') {
                      Get.defaultDialog(
                        title: 'Delete Product',
                        middleText:
                            'Are you sure you want to delete "${p.name}"?',
                        textConfirm: 'Delete',
                        textCancel: 'Cancel',
                        confirmTextColor: Colors.white,
                        buttonColor: AppTheme.error,
                        onConfirm: () {
                          Get.back();
                          controller.deleteProduct(p.id);
                        },
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
