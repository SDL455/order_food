import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_button.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_text_field.dart';
import '../widgets/settings_menu_item.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ProfileAvatar(
                photoUrl: controller.photoUrl.value.isNotEmpty ? controller.photoUrl.value : null,
                onTap: _pickPhoto,
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                controller.displayName.value.isNotEmpty
                    ? controller.displayName.value
                    : 'User',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileTextField(
                      label: 'Display Name',
                      value: controller.displayName.value,
                      icon: Icons.person_outline,
                      onChanged: (v) => controller.displayName.value = v,
                    ),
                    const SizedBox(height: 16),
                    ProfileTextField(
                      label: 'Phone Number',
                      value: controller.phone.value,
                      icon: Icons.phone_outlined,
                      onChanged: (v) => controller.phone.value = v,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => LoadingButton(
                        label: 'Save Changes',
                        isLoading: controller.isSaving.value,
                        onPressed: controller.saveProfile,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingsMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    SettingsMenuItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    SettingsMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    SettingsMenuItem(
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () {},
                      showDivider: false,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 80,
    );
    if (picked != null) {
      await controller.uploadPhoto(File(picked.path));
    }
  }

  void _confirmLogout(BuildContext context) {
    Get.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      textConfirm: 'Logout',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.error,
      onConfirm: () {
        Get.back();
        controller.logout();
      },
    );
  }
}
