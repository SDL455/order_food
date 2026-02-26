import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/app_routes.dart';

/// Manages authentication state: login, register, logout, role redirect.
class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  final isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // Form fields
  final email = ''.obs;
  final password = ''.obs;
  final displayName = ''.obs;
  final selectedRole = 'customer'.obs;

  /// Check if user is already logged in and redirect accordingly.
  Future<void> checkAuthAndRedirect() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    if (FirebaseService.isLoggedIn) {
      final user = await _repo.getUser(FirebaseService.uid);
      if (user != null) {
        currentUser.value = user;
        await _repo.refreshFcmToken();
        _redirectByRole(user.role);
        return;
      }
    }
    // Guest → go to home (shop list)
    Get.offAllNamed(AppRoutes.home);
  }

  /// Register a new user.
  Future<void> register() async {
    if (email.value.isEmpty ||
        password.value.isEmpty ||
        displayName.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    try {
      isLoading.value = true;
      final user = await _repo.register(
        email: email.value.trim(),
        password: password.value.trim(),
        displayName: displayName.value.trim(),
        role: selectedRole.value,
      );
      currentUser.value = user;
      _redirectByRole(user.role);
    } catch (e, st) {
      AppLogger.e('register failed', e, st);
      Get.snackbar('Registration Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Login an existing user.
  Future<void> login() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    try {
      isLoading.value = true;
      final user = await _repo.login(
        email: email.value.trim(),
        password: password.value.trim(),
      );
      if (user != null) {
        currentUser.value = user;
        _redirectByRole(user.role);
      } else {
        Get.snackbar('Error', 'User data not found');
      }
    } catch (e, st) {
      AppLogger.e('login failed', e, st);
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout and go to home as guest.
  Future<void> logout() async {
    await _repo.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.home);
  }

  /// Redirect based on role.
  void _redirectByRole(String role) {
    if (role == 'admin') {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Whether user is logged in.
  bool get isLoggedIn => FirebaseService.isLoggedIn;

  /// Show login dialog for guest users trying to perform restricted actions.
  void requireLogin({String message = 'Please login to continue'}) {
    Get.defaultDialog(
      title: 'Login Required',
      middleText: message,
      textConfirm: 'Login',
      textCancel: 'Cancel',
      onConfirm: () {
        Get.back();
        Get.toNamed(AppRoutes.login);
      },
    );
  }
}
