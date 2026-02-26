import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/loading_button.dart';
import '../controller/admin_product_controller.dart';

/// Admin product form screen — add or edit a product.
class AdminProductFormScreen extends GetView<AdminProductController> {
  const AdminProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.editingProduct != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: controller.imageUrl.value.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: controller.imageUrl.value,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: TextEditingController(text: controller.name.value),
              onChanged: (v) => controller.name.value = v,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.fastfood_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(
                text: controller.price.value > 0
                    ? controller.price.value.toString()
                    : '',
              ),
              onChanged: (v) =>
                  controller.price.value = double.tryParse(v) ?? 0,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(
                text: controller.category.value,
              ),
              onChanged: (v) => controller.category.value = v,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: controller.desc.value),
              onChanged: (v) => controller.desc.value = v,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_outlined),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Product is visible to customers'),
                value: controller.isActive.value,
                onChanged: (v) => controller.isActive.value = v,
                activeThumbColor: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => LoadingButton(
                label: isEditing ? 'Update Product' : 'Add Product',
                isLoading: controller.isSaving.value,
                onPressed: controller.saveProduct,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      await controller.uploadImage(File(picked.path));
    }
  }
}
