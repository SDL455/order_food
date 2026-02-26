import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'features/cart/controller/cart_controller.dart';
import 'data/repositories/auth_repository.dart';

/// Entry point — initialise Firebase, GetStorage, FCM, then run the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Local key-value storage (cart, tokens, etc.)
  await GetStorage.init();

  // CartController — available app-wide for add-to-cart from any screen
  Get.put(CartController(), permanent: true);

  // Push notifications & local notifications
  await NotificationService.instance.init();

  // Ensure latest FCM token is stored for logged-in user
  await AuthRepository().refreshFcmToken();

  runApp(const App());
}
