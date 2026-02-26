import 'dart:io';

import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/image_compression_util.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/repositories/product_repository.dart';

/// Admin product management controller — CRUD operations.
class AdminProductController extends GetxController {
  final ProductRepository _repo = ProductRepository();

  final products = <ProductModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  // Form fields
  final name = ''.obs;
  final price = 0.0.obs;
  final desc = ''.obs;
  final category = ''.obs;
  final imageUrls = <String>[].obs;
  final isActive = true.obs;

  String get shopId => Get.arguments as String? ?? '';

  /// Product being edited (null = adding new).
  ProductModel? editingProduct;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      products.value = await _repo.getAllProducts(shopId);
    } catch (e, st) {
      AppLogger.e('fetchProducts failed', e, st);
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load product data into form fields for editing.
  void loadProductForEdit(ProductModel p) {
    editingProduct = p;
    name.value = p.name;
    price.value = p.price;
    desc.value = p.desc;
    category.value = p.category;
    imageUrls.value = p.imageUrls.isNotEmpty ? List.from(p.imageUrls) : (p.imageUrl.isNotEmpty ? [p.imageUrl] : []);
    isActive.value = p.isActive;
  }

  /// Clear form fields for adding new product.
  void clearForm() {
    editingProduct = null;
    name.value = '';
    price.value = 0;
    desc.value = '';
    category.value = '';
    imageUrls.value = [];
    isActive.value = true;
  }

  /// Remove image at index.
  void removeImage(int index) {
    if (index >= 0 && index < imageUrls.length) {
      imageUrls.removeAt(index);
      imageUrls.refresh();
    }
  }

  /// Upload one or more images (compressed) and append URLs.
  Future<void> uploadImages(List<File> files) async {
    if (files.isEmpty) return;
    try {
      isSaving.value = true;
      var toUpload = await ImageCompressionUtil.compressImages(files);
      if (toUpload.isEmpty) {
        toUpload = files;
      }
      for (final file in toUpload) {
        final url = await StorageService.instance.uploadImage(
          file,
          AppConstants.productImages,
        );
        imageUrls.add(url);
      }
      imageUrls.refresh();
    } catch (e, st) {
      AppLogger.e('uploadImages failed', e, st);
      Get.snackbar('Error', 'Failed to upload image');
    } finally {
      isSaving.value = false;
    }
  }

  /// Save (add or update) product.
  Future<void> saveProduct() async {
    if (name.value.isEmpty) {
      Get.snackbar('Error', 'Product name is required');
      return;
    }
    try {
      isSaving.value = true;

      if (editingProduct != null) {
        // Update existing
        await _repo.updateProduct(shopId, editingProduct!.id, {
          'name': name.value,
          'price': price.value,
          'desc': desc.value,
          'category': category.value,
          'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
          'imageUrls': imageUrls,
          'isActive': isActive.value,
        });
      } else {
        // Add new
        final product = ProductModel(
          id: '',
          shopId: shopId,
          name: name.value,
          price: price.value,
          desc: desc.value,
          category: category.value,
          imageUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
          imageUrls: imageUrls,
          isActive: isActive.value,
        );
        await _repo.addProduct(shopId, product);
      }

      await fetchProducts();
      Get.back();
      Get.snackbar('Success', 'Product saved!');
    } catch (e, st) {
      AppLogger.e('saveProduct failed', e, st);
      Get.snackbar('Error', 'Failed to save product');
    } finally {
      isSaving.value = false;
    }
  }

  /// Soft-delete a product.
  Future<void> deleteProduct(String productId) async {
    try {
      await _repo.deleteProduct(shopId, productId);
      await fetchProducts();
      Get.snackbar('Deleted', 'Product removed');
    } catch (e, st) {
      AppLogger.e('deleteProduct failed', e, st);
      Get.snackbar('Error', 'Failed to delete product');
    }
  }
}
