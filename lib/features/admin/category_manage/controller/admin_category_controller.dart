import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';

/// Admin category management controller — CRUD for product categories.
class AdminCategoryController extends GetxController {
  final CategoryRepository _repo = CategoryRepository();

  final categories = <CategoryModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  String get shopId => Get.arguments as String? ?? '';

  // Form for add/edit
  final editingCategory = Rxn<CategoryModel>();
  final name = ''.obs;
  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> fetchCategories() async {
    if (shopId.isEmpty) return;
    try {
      isLoading.value = true;
      categories.value = await _repo.getCategories(shopId);
    } catch (e, st) {
      AppLogger.e('fetchCategories failed', e, st);
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isLoading.value = false;
    }
  }

  void loadForEdit(CategoryModel c) {
    editingCategory.value = c;
    name.value = c.name;
    nameController.text = c.name;
    nameController.selection = TextSelection.collapsed(offset: c.name.length);
  }

  void clearForm() {
    editingCategory.value = null;
    name.value = '';
    nameController.clear();
  }

  Future<void> saveCategory() async {
    final n = nameController.text.trim();
    if (n.isEmpty) {
      Get.snackbar('Error', 'Category name is required');
      return;
    }
    try {
      isSaving.value = true;
      final cat = editingCategory.value;
      if (cat != null) {
        await _repo.updateCategory(shopId, cat.id, {'name': n});
        Get.snackbar('Success', 'Category updated');
      } else {
        await _repo.addCategory(
          shopId,
          CategoryModel(id: '', shopId: shopId, name: n),
        );
        Get.snackbar('Success', 'Category added');
      }
      clearForm();
      await fetchCategories();
    } catch (e, st) {
      AppLogger.e('saveCategory failed', e, st);
      Get.snackbar('Error', 'Failed to save category');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(CategoryModel c) async {
    try {
      await _repo.deleteCategory(shopId, c.id);
      await fetchCategories();
      Get.snackbar('Deleted', 'Category removed');
    } catch (e, st) {
      AppLogger.e('deleteCategory failed', e, st);
      Get.snackbar('Error', 'Failed to delete category');
    }
  }
}
