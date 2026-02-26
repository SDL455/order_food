/// Firestore collection paths and app-wide enums/constants.
class AppConstants {
  AppConstants._();

  // ── Firestore collections ──
  static const String usersCol = 'users';
  static const String shopsCol = 'shops';
  static const String productsCol = 'products';
  static const String ordersCol = 'orders';
  static const String chatsCol = 'chats';
  static const String messagesCol = 'messages';
  static const String ratingsCol = 'ratings';
  static const String notificationsCol = 'notifications';

  // ── Storage paths ──
  static const String productImages = 'product_images';
  static const String shopImages = 'shop_images';
  static const String userImages = 'user_images';

  // ── Roles ──
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';

  // ── Order statuses ──
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusCooking = 'cooking';
  static const String statusDelivering = 'delivering';
  static const String statusDone = 'done';
  static const String statusCanceled = 'canceled';

  static const List<String> orderStatuses = [
    statusPending,
    statusAccepted,
    statusCooking,
    statusDelivering,
    statusDone,
    statusCanceled,
  ];
}
