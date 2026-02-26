import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/auth_input_field.dart';
import '../../../core/widgets/auth_prompt_row.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../routes/app_routes.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 44,
                  color: AppTheme.primary,
                ),
              )
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              )
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your food journey',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: -0.1, end: 0),
              const SizedBox(height: 40),

              AuthInputField(
                hint: 'Email address',
                icon: Icons.email_outlined,
                onChanged: (v) => controller.email.value = v,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),

              AuthInputField(
                hint: 'Password',
                icon: Icons.lock_outline,
                onChanged: (v) => controller.password.value = v,
                obscureText: true,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 24),

              Obx(
                () => LoadingButton(
                  label: 'Sign In',
                  isLoading: controller.isLoading.value,
                  onPressed: controller.login,
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                icon: const Icon(Icons.person_outline),
                label: const Text('Continue as Guest'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              )
                  .animate()
                  .fadeIn(delay: 700.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),

              AuthPromptRow(
                promptText: "Don't have an account? ",
                actionText: 'Sign Up',
                onTap: () => Get.toNamed(AppRoutes.register),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
