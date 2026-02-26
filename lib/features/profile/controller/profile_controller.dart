import 'dart:io';

import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

/// Profile controller — edit name, phone, photo.
class ProfileController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final isLoading = true.obs;
  final isSaving = false.obs;

  final displayName = ''.obs;
  final phone = ''.obs;
  final photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      isLoading.value = true;
      final u = await _repo.getUser(FirebaseService.uid);
      if (u != null) {
        user.value = u;
        displayName.value = u.displayName;
        phone.value = u.phone;
        photoUrl.value = u.photoUrl;
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload profile photo.
  Future<void> uploadPhoto(File file) async {
    try {
      isSaving.value = true;
      final url = await StorageService.instance.uploadImage(
        file,
        AppConstants.userImages,
      );
      photoUrl.value = url;
    } catch (e, st) {
      AppLogger.e('uploadPhoto failed', e, st);
      Get.snackbar('Error', 'Failed to upload photo');
    } finally {
      isSaving.value = false;
    }
  }

  /// Save profile changes.
  Future<void> saveProfile() async {
    try {
      isSaving.value = true;
      await _repo.updateUser(FirebaseService.uid, {
        'displayName': displayName.value,
        'phone': phone.value,
        'photoUrl': photoUrl.value,
      });
      Get.snackbar('Success', 'Profile updated!');
    } catch (e, st) {
      AppLogger.e('saveProfile failed', e, st);
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isSaving.value = false;
    }
  }

  /// Logout.
  Future<void> logout() async {
    await FirebaseService.auth.signOut();
    Get.offAllNamed(AppRoutes.home);
  }
}
