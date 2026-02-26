import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/auth_input_field.dart';
import '../../../core/widgets/auth_prompt_row.dart';
import '../../../core/widgets/loading_button.dart';
import '../controller/auth_controller.dart';
import '../widgets/role_card.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join Us!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              )
                  .animate()
                  .fadeIn()
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Create an account to start ordering',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 32),

              AuthInputField(
                hint: 'Full Name',
                icon: Icons.person_outline,
                onChanged: (v) => controller.displayName.value = v,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),

              AuthInputField(
                hint: 'Email address',
                icon: Icons.email_outlined,
                onChanged: (v) => controller.email.value = v,
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),

              AuthInputField(
                hint: 'Password',
                icon: Icons.lock_outline,
                onChanged: (v) => controller.password.value = v,
                obscureText: true,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),

              Text(
                'I want to:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: RoleCard(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Order Food',
                        subtitle: 'Customer',
                        isSelected:
                            controller.selectedRole.value == AppConstants.roleCustomer,
                        onTap: () => controller.selectedRole.value = AppConstants.roleCustomer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RoleCard(
                        icon: Icons.store_outlined,
                        label: 'Sell Food',
                        subtitle: 'Shop Admin',
                        isSelected:
                            controller.selectedRole.value == AppConstants.roleAdmin,
                        onTap: () => controller.selectedRole.value = AppConstants.roleAdmin,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),

              Obx(
                () => LoadingButton(
                  label: 'Create Account',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.register,
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),

              AuthPromptRow(
                promptText: 'Already have an account? ',
                actionText: 'Sign In',
                onTap: () => Get.back(),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
