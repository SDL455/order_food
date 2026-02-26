import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../../data/models/rating_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/rating_repository.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/app_logger.dart';

/// Controller for the product detail screen.
class ProductDetailController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final RatingRepository _ratingRepo = RatingRepository();

  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final ratings = <RatingModel>[].obs;
  final isLoading = true.obs;

  // Rating form
  final userStars = 5.0.obs;
  final userComment = ''.obs;

  String get shopId => (Get.arguments as Map)['shopId'] ?? '';
  String get productId => (Get.arguments as Map)['productId'] ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading.value = true;
      product.value = await _productRepo.getProduct(shopId, productId);
      ratings.value = await _ratingRepo.getRatings(shopId, productId);
    } catch (e, st) {
      AppLogger.e('_load product failed', e, st);
      Get.snackbar('Error', 'Failed to load product');
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit a rating for this product.
  Future<void> submitRating() async {
    if (!FirebaseService.isLoggedIn) {
      Get.snackbar('Login Required', 'Please login to rate this product');
      return;
    }
    try {
      final rating = RatingModel(
        uid: FirebaseService.uid,
        stars: userStars.value,
        comment: userComment.value,
      );
      await _ratingRepo.addRating(
        shopId: shopId,
        productId: productId,
        rating: rating,
      );
      await _load(); // Refresh product + ratings
      Get.snackbar('Success', 'Rating submitted!');
    } catch (e, st) {
      AppLogger.e('submitRating failed', e, st);
      Get.snackbar('Error', 'Failed to submit rating');
    }
  }
}
