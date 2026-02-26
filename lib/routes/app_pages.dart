import 'package:get/get.dart';

import '../routes/app_routes.dart';

// Feature bindings
import '../features/auth/binding/auth_binding.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/register_screen.dart';

import '../features/home/binding/home_binding.dart';
import '../features/home/views/shop_list_screen.dart';

import '../features/shop/binding/shop_binding.dart';
import '../features/shop/views/shop_detail_screen.dart';

import '../features/product/binding/product_binding.dart';
import '../features/product/views/product_detail_screen.dart';

import '../features/cart/binding/cart_binding.dart';
import '../features/cart/views/cart_screen.dart';

import '../features/checkout/binding/checkout_binding.dart';
import '../features/checkout/views/checkout_screen.dart';

import '../features/orders/binding/orders_binding.dart';
import '../features/orders/views/orders_screen.dart';

import '../features/chat/binding/chat_binding.dart';
import '../features/chat/views/chat_list_screen.dart';
import '../features/chat/views/chat_screen.dart';

import '../features/profile/binding/profile_binding.dart';
import '../features/profile/views/profile_screen.dart';

import '../features/admin/dashboard/binding/admin_dashboard_binding.dart';
import '../features/admin/dashboard/views/admin_dashboard_screen.dart';

import '../features/admin/product_manage/binding/admin_product_binding.dart';
import '../features/admin/product_manage/views/admin_product_list_screen.dart';
import '../features/admin/product_manage/views/admin_product_form_screen.dart';

import '../features/admin/category_manage/binding/admin_category_binding.dart';
import '../features/admin/category_manage/views/admin_category_screen.dart';

import '../features/admin/order_manage/binding/admin_order_binding.dart';
import '../features/admin/order_manage/views/admin_orders_screen.dart';

/// All GetPages for the app, wired to routes + bindings.
class AppPages {
  static final pages = <GetPage>[
    // ── Auth ──
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),

    // ── Customer ──
    GetPage(
      name: AppRoutes.home,
      page: () => const ShopListScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.shopDetail,
      page: () => const ShopDetailScreen(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatDetailScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),

    // ── Admin ──
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardScreen(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.adminProducts,
      page: () => const AdminProductListScreen(),
      binding: AdminProductBinding(),
    ),
    GetPage(
      name: AppRoutes.adminProductForm,
      page: () => const AdminProductFormScreen(),
      binding: AdminProductBinding(),
    ),
    GetPage(
      name: AppRoutes.adminCategories,
      page: () => const AdminCategoryScreen(),
      binding: AdminCategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.adminOrders,
      page: () => const AdminOrdersScreen(),
      binding: AdminOrderBinding(),
    ),
    GetPage(
      name: AppRoutes.adminChatList,
      page: () => const ChatListScreen(),
      binding: ChatBinding(),
    ),
  ];
}
