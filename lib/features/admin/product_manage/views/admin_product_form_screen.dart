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
              () {
                final urls = controller.imageUrls.toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Images',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...urls.asMap().entries.map(
                              (e) => _buildImageChip(
                                url: e.value,
                                onRemove: () => controller.removeImage(e.key),
                              ),
                            ),
                        _buildAddImageButton(),
                      ],
                    ),
                    if (urls.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Tap + to add images (compressed before upload)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                );
              },
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

  Widget _buildImageChip({
    required String url,
    required VoidCallback onRemove,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: AppTheme.textSecondary),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(limit: 10);
    if (picked.isEmpty) return;
    final files = <File>[];
    for (final x in picked) {
      if (x.path.isNotEmpty) {
        final f = File(x.path);
        if (await f.exists()) files.add(f);
      }
    }
    if (files.isNotEmpty) {
      await controller.uploadImages(files);
    } else {
      Get.snackbar('Error', 'Could not read selected images');
    }
  }
}
